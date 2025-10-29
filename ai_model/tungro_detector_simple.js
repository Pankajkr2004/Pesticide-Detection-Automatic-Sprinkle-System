const sharp = require('sharp');

class IntensityBasedTungroDetector {
  constructor() {
    // Updated thresholds - intensity-focused detection
    this.thresholds = {
      min_area_percentage: 0.5,    // Reduced from 0.8% to 0.5%
      min_intensity_score: 0.25,   // Primary threshold - focus on this
      tungro_confidence_min: 0.70
    };
    
    // Heavily weighted toward intensity
    this.weights = {
      intensity_weight: 0.95,      // Increased from 85% to 95%
      area_weight: 0.05           // Decreased from 15% to 5%
    };

    // More selective yellow ranges - higher saturation for true tungro
    this.yellow_hsv_ranges = {
      'light_yellow': {
        lower: [18, 100, 120],   // Higher saturation threshold
        upper: [25, 255, 255]  
      },
      'medium_yellow': {
        lower: [15, 120, 140],   
        upper: [22, 255, 255]  
      },
      'intense_yellow': {
        lower: [12, 140, 160],   // Very selective
        upper: [20, 255, 255]
      },
      'deep_yellow': {
        lower: [10, 160, 120],   // Most selective
        upper: [18, 255, 220]
      }
    };

    this.plant_ranges = [
      { lower: [30, 50, 50], upper: [80, 255, 255] },   
      { lower: [20, 60, 80], upper: [30, 255, 255] },   
      { lower: [10, 80, 100], upper: [25, 255, 255] },  
    ];
  }
  
  async processImageBuffer(imageBuffer) {
    const startTime = Date.now();
    
    try {
      console.log('Processing with intensity-focused detection...');
      
      const image = sharp(imageBuffer);
      const metadata = await image.metadata();
      
      const { data, info } = await image
        .png()
        .raw()
        .toBuffer({ resolveWithObject: true });
      
      const hsvData = this.rgbToHsv(data, info.width, info.height);
      const plantMask = this.createPlantMask(hsvData, info.width, info.height);
      const totalPlantPixels = this.countNonZero(plantMask);
      
      console.log(`Total plant pixels: ${totalPlantPixels}`);
      
      if (totalPlantPixels === 0) {
        return this.createResult('healthy', 95, this.emptyAnalysis());
      }
      
      const yellowAnalysis = this.analyzeYellowInPlants(hsvData, plantMask, info.width, info.height, totalPlantPixels);
      
      // Intensity-focused decision making
      let prediction, finalConfidence;
      
      const intensityScore = yellowAnalysis.yellow_intensity_score || 0;
      const areaPercentage = yellowAnalysis.yellow_area_percentage || 0;
      const confidence = yellowAnalysis.confidence || 0;
      
      console.log(`INTENSITY-FOCUSED ANALYSIS:`);
      console.log(`- Intensity Score: ${intensityScore.toFixed(3)} (threshold: ${this.thresholds.min_intensity_score})`);
      console.log(`- Area Percentage: ${areaPercentage.toFixed(2)}% (threshold: ${this.thresholds.min_area_percentage}%)`);
      console.log(`- Yellow Pixels: ${yellowAnalysis.yellow_pixels_total}`);
      console.log(`- Weighted Confidence: ${confidence.toFixed(3)}`);
      
      // Primary decision based on intensity
      const meetsIntensityThreshold = intensityScore >= this.thresholds.min_intensity_score;
      const meetsAreaThreshold = areaPercentage >= this.thresholds.min_area_percentage;
      
      console.log(`- Intensity Check: ${meetsIntensityThreshold} (${intensityScore.toFixed(3)} >= ${this.thresholds.min_intensity_score})`);
      console.log(`- Area Check: ${meetsAreaThreshold} (${areaPercentage.toFixed(2)}% >= ${this.thresholds.min_area_percentage}%)`);
      
      // Decision logic: Either high intensity OR (moderate intensity + area)
      let isTungro = false;
      
      if (intensityScore >= 0.35) {
        // High intensity alone is enough
        isTungro = true;
        console.log(`HIGH INTENSITY DETECTION: ${intensityScore.toFixed(3)} >= 0.35`);
      } else if (meetsIntensityThreshold && meetsAreaThreshold) {
        // Moderate intensity + area requirement
        isTungro = true;
        console.log(`MODERATE INTENSITY + AREA DETECTION`);
      } else {
        isTungro = false;
        console.log(`NO TUNGRO: Intensity too low or area insufficient`);
      }
      
      if (isTungro) {
        prediction = 'tungro';
        // Calculate confidence based heavily on intensity
        const intensityConfidence = Math.min(intensityScore / 0.5, 1.0); // Scale intensity to confidence
        finalConfidence = Math.max(70, Math.round(intensityConfidence * 100));
      } else {
        prediction = 'healthy';
        finalConfidence = Math.max(75, 100 - Math.round(intensityScore * 200)); // Higher confidence for lower intensity
      }
      
      const processingTime = (Date.now() - startTime) / 1000;
      
      console.log(`FINAL DECISION: ${prediction} (${finalConfidence}%)`);
      
      // Update the analysis object with our decision
      yellowAnalysis.is_detected = isTungro;
      yellowAnalysis.confidence = isTungro ? finalConfidence / 100 : (100 - finalConfidence) / 100;
      
      return this.createResult(prediction, finalConfidence, yellowAnalysis, processingTime);
      
    } catch (error) {
      console.error('Processing error:', error);
      throw error;
    }
  }
  
  rgbToHsv(rgbData, width, height) {
    const hsvData = new Array(rgbData.length);
    
    for (let i = 0; i < rgbData.length; i += 3) {
      const r = rgbData[i] / 255.0;
      const g = rgbData[i + 1] / 255.0;
      const b = rgbData[i + 2] / 255.0;
      
      const max = Math.max(r, g, b);
      const min = Math.min(r, g, b);
      const delta = max - min;
      
      let h = 0, s = 0, v = max;
      
      if (delta !== 0 && max !== 0) {
        s = delta / max;
        
        if (max === r) {
          h = ((g - b) / delta) % 6;
        } else if (max === g) {
          h = (b - r) / delta + 2;
        } else {
          h = (r - g) / delta + 4;
        }
        h = h * 60;
        if (h < 0) h += 360;
      }
      
      hsvData[i] = Math.round(h / 2);         
      hsvData[i + 1] = Math.round(s * 255);   
      hsvData[i + 2] = Math.round(v * 255);   
    }
    
    return hsvData;
  }
  
  createPlantMask(hsvData, width, height) {
    const mask = new Array(width * height).fill(0);
    
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const idx = (y * width + x) * 3;
        const h = hsvData[idx] || 0;
        const s = hsvData[idx + 1] || 0;
        const v = hsvData[idx + 2] || 0;
        
        let isPlant = false;
        for (const range of this.plant_ranges) {
          if (h >= range.lower[0] && h <= range.upper[0] &&
              s >= range.lower[1] && s <= range.upper[1] &&
              v >= range.lower[2] && v <= range.upper[2]) {
            isPlant = true;
            break;
          }
        }
        
        if (v < 50) isPlant = false;
        
        mask[y * width + x] = isPlant ? 1 : 0;
      }
    }
    
    return mask;
  }
  
  analyzeYellowInPlants(hsvData, plantMask, width, height, totalPlantPixels) {
    let yellowPixelsTotal = 0;
    let intensityValues = [];
    let maxIntensity = 0;
    
    for (const [rangeName, range] of Object.entries(this.yellow_hsv_ranges)) {
      let rangeYellowPixels = 0;
      let rangeSatSum = 0;
      let rangeValSum = 0;
      
      for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
          const pixelIdx = y * width + x;
          const hsvIdx = pixelIdx * 3;
          
          if (plantMask[pixelIdx] === 0) continue;
          
          const h = hsvData[hsvIdx] || 0;
          const s = hsvData[hsvIdx + 1] || 0;
          const v = hsvData[hsvIdx + 2] || 0;
          
          if (h >= range.lower[0] && h <= range.upper[0] &&
              s >= range.lower[1] && s <= range.upper[1] &&
              v >= range.lower[2] && v <= range.upper[2]) {
            
            rangeYellowPixels++;
            rangeSatSum += s;
            rangeValSum += v;
          }
        }
      }
      
      yellowPixelsTotal += rangeYellowPixels;
      
      if (rangeYellowPixels > 0) {
        const avgSat = rangeSatSum / rangeYellowPixels;
        const avgVal = rangeValSum / rangeYellowPixels;
        const rangeIntensity = (avgSat * avgVal) / (255.0 * 255.0);
        
        intensityValues.push(rangeIntensity);
        maxIntensity = Math.max(maxIntensity, rangeIntensity);
        
        console.log(`${rangeName}: ${rangeYellowPixels} pixels, intensity: ${rangeIntensity.toFixed(3)}`);
      }
    }
    
    const areaPercentage = totalPlantPixels > 0 ? (yellowPixelsTotal / totalPlantPixels) * 100 : 0;
    const avgIntensity = intensityValues.length > 0 ? intensityValues.reduce((a, b) => a + b) / intensityValues.length : 0;
    const intensityScore = maxIntensity || 0;
    
    return {
      yellow_area_percentage: areaPercentage,
      yellow_intensity_score: intensityScore,
      yellow_pixels_total: yellowPixelsTotal,
      total_plant_pixels: totalPlantPixels,
      confidence: 0, // Will be calculated later
      is_detected: false, // Will be determined later
      severity: 'none',
      max_intensity: maxIntensity || 0,
      avg_intensity: avgIntensity || 0
    };
  }
  
  countNonZero(mask) {
    return mask.reduce((count, val) => count + (val > 0 ? 1 : 0), 0);
  }
  
  createResult(prediction, confidence, yellowAnalysis, processingTime = 0) {
    return {
      prediction: prediction,
      confidence: confidence,
      yellow_analysis: yellowAnalysis,
      processingTime: processingTime
    };
  }
  
  emptyAnalysis() {
    return {
      yellow_area_percentage: 0,
      yellow_intensity_score: 0,
      yellow_pixels_total: 0,
      total_plant_pixels: 0,
      confidence: 0.0,
      is_detected: false,
      severity: 'none',
      max_intensity: 0.0,
      avg_intensity: 0.0
    };
  }
}

module.exports = { AdvancedTungroDetector: IntensityBasedTungroDetector };