const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { AdvancedTungroDetector } = require('./tungro_detector_simple');

// Initialize Firebase Admin (only once)
admin.initializeApp();

// ============================================
// FUNCTION 1: Process uploaded images with AI
// ============================================
exports.processPlantImage = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '2GB'
  })
  .storage.object().onFinalize(async (object) => {
    const filePath = object.name;
    
    // Skip if not in uploads folder or already processed
    if (!filePath.startsWith('uploads/')) return null;
    if (filePath.includes('highlighted')) return null;
    
    console.log('Processing new image:', filePath);
    
    const imageId = filePath.split('/').pop().split('.')[0];
    
    try {
      // Use advanced detector
      const detector = new AdvancedTungroDetector();
      
      const bucket = admin.storage().bucket();
      const file = bucket.file(filePath);
      const [imageBuffer] = await file.download();
      
      const result = await detector.processImageBuffer(imageBuffer);
      
      // Save results to Firestore (this will trigger the notification function)
      await admin.firestore().collection('tungro_results').doc(imageId).set({
        imageId: imageId,
        originalPath: filePath,
        prediction: result.prediction,
        confidence: result.confidence,
        yellowAnalysis: result.yellow_analysis,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'completed',
        processingTimeSeconds: result.processingTime || 0
      });
      
      console.log(`Success: ${result.prediction} (${result.confidence}%)`);
      return null;
      
    } catch (error) {
      console.error('Error processing image:', error);
      await admin.firestore().collection('tungro_results').doc(imageId).set({
        imageId: imageId,
        originalPath: filePath,
        error: error.message,
        status: 'failed',
        processedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      return null;
    }
  });

// ============================================
// FUNCTION 2: Send notification when Tungro detected
// ============================================
exports.onTungroDetection = functions.firestore
  .document('tungro_results/{resultId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const prediction = data.prediction?.toLowerCase();
    
    // Only send notification if Tungro is detected and processing succeeded
    if (data.status === 'completed' && prediction && prediction.includes('tungro')) {
      const message = {
        notification: {
          title: '⚠️ Tungro Alert!',
          body: `Tungro virus detected with ${data.confidence}% confidence. Immediate action required!`,
        },
        data: {
          type: 'tungro_detection',
          imageId: data.imageId || '',
          confidence: String(data.confidence || 0),
          timestamp: String(Date.now()),
        },
        topic: 'all_users',
      };

      try {
        const response = await admin.messaging().send(message);
        console.log('Successfully sent notification:', response);
        
        // Update the document to mark notification as sent
        await snap.ref.update({
          notificationSent: true,
          notificationSentAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        return response;
      } catch (error) {
        console.error('Error sending notification:', error);
        
        // Mark notification as failed
        await snap.ref.update({
          notificationSent: false,
          notificationError: error.message
        });
        
        return null;
      }
    }
    
    console.log('No notification sent - either not Tungro or processing failed');
    return null;
  });

// ============================================
// FUNCTION 3: Manual notification trigger (optional)
// ============================================
exports.sendTungroAlert = functions.https.onCall(async (data, context) => {
  const message = {
    notification: {
      title: data.title || '⚠️ Tungro Alert!',
      body: data.body || 'Tungro virus detected in your plant!',
    },
    data: {
      type: 'tungro_detection',
      ...data.extraData,
    },
    topic: 'all_users',
  };

  try {
    const response = await admin.messaging().send(message);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending notification:', error);
    return { success: false, error: error.message };
  }
});

// ============================================
// FUNCTION 4: Subscribe user to notifications
// ============================================
exports.subscribeToTopic = functions.https.onCall(async (data, context) => {
  const { token } = data;
  
  if (!token) {
    return { success: false, error: 'Token is required' };
  }
  
  try {
    const response = await admin.messaging().subscribeToTopic(token, 'all_users');
    console.log('Successfully subscribed to topic:', response);
    return { success: true };
  } catch (error) {
    console.error('Error subscribing to topic:', error);
    return { success: false, error: error.message };
  }
});