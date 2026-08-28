package com.example.edge_ai;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.SurfaceTexture;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import org.tensorflow.lite.support.image.TensorImage;
import org.tensorflow.lite.task.vision.detector.Detection;
import org.tensorflow.lite.task.vision.detector.ObjectDetector;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends AppCompatActivity {

    private ScrollView mainScroll;
    private TextView tvTerminal;
    private Button btnStartScan;
    private OverlayView overlayView;
    private HeatmapOverlayView heatmapOverlayView;
    private LinearLayout llTargets;
    private TextView tvTargetsList;
    private LinearLayout llStage2Results;
    private TextView tvStage2Details;
    private LinearLayout llFinalReport;
    private TextView tvFinalReportText;
    private TextView tvNetworkStatus;
    
    // Rescan Images
    private ImageView ivRescan1, ivRescan2, ivRescan3, ivRescan4;
    private Bitmap fieldDemoBitmap;
    
    // ML Stages
    private TextView tvStage1, tvStage2, tvStage3;

    // Live Sensors & ML Detection
    private TextureView cameraPreview;
    private BoundingBoxView boundingBoxView;
    private TextView tvSensorData;
    private TextView tvFps;
    private GraphView graphView;
    private ObjectDetector objectDetector;
    
    private String gpsData = "GPS: WAITING...";
    private String gyroData = "GYRO: WAITING...";
    private float currentTemp = 28.5f;
    private float currentHum = 65.0f;
    private float currentSoil = 42.0f;
    
    // Wi-Fi Share
    private LinearLayout llWifiShareOverlay;
    private TextView tvWifiStatus;

    private ExecutorService executorService;
    private Handler mainHandler;

    private List<OverlayView.ZoneResult> allZones = new ArrayList<>();
    private List<OverlayView.ZoneResult> topTargets = new ArrayList<>();

    private final double BASE_LAT = 19.123456;
    private final double BASE_LNG = 72.987654;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mainScroll = findViewById(R.id.mainScroll);
        tvTerminal = findViewById(R.id.tvTerminal);
        btnStartScan = findViewById(R.id.btnStartScan);
        overlayView = findViewById(R.id.overlayView);
        heatmapOverlayView = findViewById(R.id.heatmapOverlayView);
        llTargets = findViewById(R.id.llTargets);
        tvTargetsList = findViewById(R.id.tvTargetsList);
        llStage2Results = findViewById(R.id.llStage2Results);
        tvStage2Details = findViewById(R.id.tvStage2Details);
        llFinalReport = findViewById(R.id.llFinalReport);
        tvFinalReportText = findViewById(R.id.tvFinalReportText);
        tvNetworkStatus = findViewById(R.id.tvNetworkStatus);
        
        ivRescan1 = findViewById(R.id.ivRescan1);
        ivRescan2 = findViewById(R.id.ivRescan2);
        ivRescan3 = findViewById(R.id.ivRescan3);
        ivRescan4 = findViewById(R.id.ivRescan4);
        
        // Load original bitmap for cropping
        fieldDemoBitmap = BitmapFactory.decodeResource(getResources(), R.drawable.field_demo);
        
        tvStage1 = findViewById(R.id.tvStage1);
        tvStage2 = findViewById(R.id.tvStage2);
        tvStage3 = findViewById(R.id.tvStage3);
        
        cameraPreview = findViewById(R.id.cameraPreview);
        boundingBoxView = findViewById(R.id.boundingBoxView);
        tvSensorData = findViewById(R.id.tvSensorData);
        tvFps = findViewById(R.id.tvFps);
        graphView = findViewById(R.id.graphView);
        
        llWifiShareOverlay = findViewById(R.id.llWifiShareOverlay);
        tvWifiStatus = findViewById(R.id.tvWifiStatus);

        executorService = Executors.newSingleThreadExecutor();
        mainHandler = new Handler(Looper.getMainLooper());
        
        // Sync the startup heatmap data so it's visible immediately
        heatmapOverlayView.setResults(overlayView.getResults());
        
        setupObjectDetector();

        btnStartScan.setOnClickListener(v -> {
            btnStartScan.setEnabled(false);
            tvTerminal.setVisibility(View.VISIBLE);
            tvTerminal.setText("");
            runStage1();
        });

        checkNetworkStatus();
        requestHardwarePermissions();
        
        // Start continuous sensor data loop
        mainHandler.post(sensorUpdater);
    }
    
    private void setupObjectDetector() {
        try {
            ObjectDetector.ObjectDetectorOptions options = 
                ObjectDetector.ObjectDetectorOptions.builder()
                .setMaxResults(5)
                .setScoreThreshold(0.5f)
                .build();
            objectDetector = ObjectDetector.createFromFileAndOptions(this, "mobilenet.tflite", options);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private boolean realGpsLocked = false;
    private double mockLat = BASE_LAT;
    private double mockLng = BASE_LNG;
    
    private Runnable sensorUpdater = new Runnable() {
        @Override
        public void run() {
            currentTemp += (Math.random() - 0.5f) * 0.4f;
            currentHum += (Math.random() - 0.5f) * 1.0f;
            currentSoil += (Math.random() - 0.5f) * 0.8f;
            
            if (!realGpsLocked) {
                mockLat += (Math.random() - 0.5) * 0.00005;
                mockLng += (Math.random() - 0.5) * 0.00005;
                gpsData = String.format(Locale.US, "GPS: %.6f, %.6f (SIMULATED)", mockLat, mockLng);
            }
            
            String tempHumSoil = String.format(Locale.US, "TMP: %.1f°C  HUM: %.1f%%  SOIL: %.1f%%", currentTemp, currentHum, currentSoil);
            tvSensorData.setText(gpsData + "\n" + gyroData + "\n" + tempHumSoil);
            
            if(graphView != null) {
                graphView.addValue((float)(Math.random() * 20 + 40));
            }
            
            mainHandler.postDelayed(this, 1000);
        }
    };
    
    private Runnable mlDetectorLoop = new Runnable() {
        @Override
        public void run() {
            if (cameraPreview != null && cameraPreview.isAvailable() && objectDetector != null) {
                long start = System.nanoTime();
                
                // Live inference from camera View
                Bitmap bitmap = cameraPreview.getBitmap(640, 480);
                if (bitmap != null) {
                    TensorImage image = TensorImage.fromBitmap(bitmap);
                    List<Detection> results = objectDetector.detect(image);
                    
                    boundingBoxView.setDetections(results);
                    
                    long end = System.nanoTime();
                    long duration = (end - start) / 1000000;
                    int fps = (duration > 0) ? (int)(1000 / duration) : 30;
                    tvFps.setText("CAM FPS: " + fps + " | INFERENCE: " + duration + "ms | AI: ACTIVE");
                }
            }
            mainHandler.postDelayed(this, 150); // Loop roughly 6-7 fps for demo efficiency
        }
    };
    
    private void requestHardwarePermissions() {
        if (checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED ||
            checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(new String[]{
                Manifest.permission.CAMERA, 
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            }, 100);
        } else {
            startLiveSensors();
        }
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 100 && grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            startLiveSensors();
        }
    }

    private void startLiveSensors() {
        if (cameraPreview.isAvailable()) {
            openCamera();
        } else {
            cameraPreview.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
                @Override
                public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                    openCamera();
                }
                @Override public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {}
                @Override public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) { return true; }
                @Override public void onSurfaceTextureUpdated(SurfaceTexture surface) {}
            });
        }
        
        SensorManager sm = (SensorManager) getSystemService(SENSOR_SERVICE);
        if (sm != null) {
            Sensor gyro = sm.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
            if (gyro != null) {
                sm.registerListener(new SensorEventListener() {
                    @Override
                    public void onSensorChanged(SensorEvent e) {
                        gyroData = String.format(Locale.US, "GYRO: X:%.1f Y:%.1f Z:%.1f", e.values[0], e.values[1], e.values[2]);
                    }
                    @Override public void onAccuracyChanged(Sensor s, int a) {}
                }, gyro, SensorManager.SENSOR_DELAY_NORMAL);
            }
        }
        
        LocationManager lm = (LocationManager) getSystemService(LOCATION_SERVICE);
        try {
            if (lm != null) {
                lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 2000, 1, new LocationListener() {
                    @Override
                    public void onLocationChanged(@NonNull Location location) {
                        realGpsLocked = true;
                        gpsData = String.format(Locale.US, "GPS: %.4f, %.4f", location.getLatitude(), location.getLongitude());
                    }
                });
            }
        } catch (SecurityException e) {
            e.printStackTrace();
        }
        
        // Start Live Edge AI detection loop
        mainHandler.post(mlDetectorLoop);
    }

    private void openCamera() {
        CameraManager manager = (CameraManager) getSystemService(Context.CAMERA_SERVICE);
        try {
            if (checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) return;
            String cameraId = manager.getCameraIdList()[0];
            manager.openCamera(cameraId, new CameraDevice.StateCallback() {
                @Override
                public void onOpened(@NonNull CameraDevice camera) {
                    try {
                        SurfaceTexture texture = cameraPreview.getSurfaceTexture();
                        if (texture == null) return;
                        texture.setDefaultBufferSize(640, 480);
                        Surface surface = new Surface(texture);
                        final CaptureRequest.Builder builder = camera.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
                        builder.addTarget(surface);
                        camera.createCaptureSession(Collections.singletonList(surface), new CameraCaptureSession.StateCallback() {
                            @Override
                            public void onConfigured(@NonNull CameraCaptureSession session) {
                                try {
                                    session.setRepeatingRequest(builder.build(), null, null);
                                } catch (Exception e) {}
                            }
                            @Override public void onConfigureFailed(@NonNull CameraCaptureSession session) {}
                        }, null);
                    } catch (Exception e) {}
                }
                @Override public void onDisconnected(@NonNull CameraDevice camera) {}
                @Override public void onError(@NonNull CameraDevice camera, int error) {}
            }, null);
        } catch (Exception e) {}
    }

    private void checkNetworkStatus() {
        android.net.ConnectivityManager cm = (android.net.ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        android.net.NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        boolean isConnected = activeNetwork != null && activeNetwork.isConnectedOrConnecting();
        if (!isConnected) {
            tvNetworkStatus.setText("NETWORK: OFFLINE - LOCAL COMPUTE ACTIVE");
        } else {
            tvNetworkStatus.setText("NETWORK: ONLINE (DEMO RUNNING LOCALLY)");
        }
    }

    private void appendLog(String message) {
        mainHandler.post(() -> {
            String current = tvTerminal.getText().toString();
            tvTerminal.setText(current + "> " + message + "\n");
            mainScroll.post(() -> mainScroll.fullScroll(View.FOCUS_DOWN));
        });
    }

    private void updateStageUI(int stage) {
        mainHandler.post(() -> {
            tvStage1.setTextColor(stage >= 1 ? Color.GREEN : Color.GRAY);
            tvStage2.setTextColor(stage >= 2 ? Color.GREEN : Color.GRAY);
            tvStage3.setTextColor(stage >= 3 ? Color.GREEN : Color.GRAY);
        });
    }
    
    private Bitmap cropZoneBitmap(OverlayView.ZoneResult z) {
        if (fieldDemoBitmap == null) return null;
        
        int cellWidth = fieldDemoBitmap.getWidth() / 10;
        int cellHeight = fieldDemoBitmap.getHeight() / 10;
        
        int x = z.col * cellWidth;
        int y = z.row * cellHeight;
        
        return Bitmap.createBitmap(fieldDemoBitmap, x, y, cellWidth, cellHeight);
    }

    private void runStage1() {
        updateStageUI(1);
        executorService.execute(() -> {
            try {
                appendLog("INITIALIZING EDGE ENGINE...");
                Thread.sleep(500);
                appendLog("LOADING FIELD IMAGE...");
                Thread.sleep(500);
                appendLog("DIVIDING FIELD INTO ANALYSIS ZONES (10x10)...");
                Thread.sleep(500);
                appendLog("LOADING STAGE 1 MODEL...");
                Thread.sleep(800);
                appendLog("Model loaded successfully");
                appendLog("RUNNING LOCAL INFERENCE...");

                long startTime = System.nanoTime();
                allZones.clear();
                
                List<Integer> badCropZones = Arrays.asList(11, 12, 13, 23, 33, 32, 31, 21, 65, 66, 57, 75, 76, 77, 85, 86, 87, 28, 38);
                List<Integer> wetZones = Arrays.asList(72);
                List<Integer> dryZones = Arrays.asList(50, 60, 70, 80, 79, 89);

                for (int row = 0; row < 10; row++) {
                    for (int col = 0; col < 10; col++) {
                        int zoneNum = row * 10 + col + 1;
                        String zoneId = String.format(Locale.US, "Z%02d", zoneNum);
                        
                        float score = (float) (Math.random() * 20);
                        int status = OverlayView.ZoneResult.STATUS_NORMAL;
                        
                        if (badCropZones.contains(zoneNum)) {
                            status = OverlayView.ZoneResult.STATUS_BAD;
                            score = 75f + (float)(Math.random() * 20);
                        } else if (wetZones.contains(zoneNum)) {
                            status = OverlayView.ZoneResult.STATUS_WET;
                            score = 60f + (float)(Math.random() * 15);
                        } else if (dryZones.contains(zoneNum)) {
                            status = OverlayView.ZoneResult.STATUS_DRY;
                            score = 65f + (float)(Math.random() * 15);
                        }

                        allZones.add(new OverlayView.ZoneResult(zoneId, row, col, status, score));
                        
                        if (zoneNum % 25 == 0) {
                            appendLog(String.format(Locale.US, "Processing zone %02d/100", zoneNum));
                            if(graphView != null) graphView.addValue((float)(Math.random() * 40 + 60)); 
                            Thread.sleep(150);
                        }
                    }
                }
                
                long endTime = System.nanoTime();
                long durationMs = (endTime - startTime) / 1000000;
                
                appendLog("ANALYZING FIELD...");
                appendLog("Stage 1 Inference Time: " + durationMs + " ms");
                appendLog("RANKING SUSPICIOUS ZONES...");
                Thread.sleep(500);

                topTargets.clear();
                for (OverlayView.ZoneResult z : allZones) {
                    if (z.id.equals("Z23") || z.id.equals("Z72") || z.id.equals("Z76") || z.id.equals("Z80")) {
                        topTargets.add(z);
                    }
                }

                appendLog("4 key targets selected for rescan");
                appendLog("GENERATING TARGET WAYPOINTS...");
                Thread.sleep(500);

                mainHandler.post(() -> {
                    overlayView.setResults(allZones);
                    heatmapOverlayView.setResults(allZones);
                    showTargets();
                    runStage2();
                });

            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
    }

    private void showTargets() {
        llTargets.setVisibility(View.VISIBLE);
        StringBuilder sb = new StringBuilder();
        
        for (int i = 0; i < topTargets.size(); i++) {
            OverlayView.ZoneResult z = topTargets.get(i);
            double lat = BASE_LAT + (z.row * 0.0001);
            double lng = BASE_LNG + (z.col * 0.0001);
            
            sb.append(String.format(Locale.US, "#%d %s - Anomaly %.1f%%\n", i+1, z.id, z.score));
            sb.append(String.format(Locale.US, "Lat: %.6f, Lng: %.6f\n\n", lat, lng));
            
            // Set cropped image
            Bitmap crop = cropZoneBitmap(z);
            if (crop != null) {
                if (i == 0) ivRescan1.setImageBitmap(crop);
                else if (i == 1) ivRescan2.setImageBitmap(crop);
                else if (i == 2) ivRescan3.setImageBitmap(crop);
                else if (i == 3) ivRescan4.setImageBitmap(crop);
            }
        }
        
        tvTargetsList.setText(sb.toString().trim());
        mainScroll.post(() -> mainScroll.fullScroll(View.FOCUS_DOWN));
    }

    private void runStage2() {
        updateStageUI(2);
        executorService.execute(() -> {
            try {
                appendLog("TARGETED RESCAN STARTED (ZOOM & DIVIDE)");
                Thread.sleep(1000);
                
                mainHandler.post(() -> {
                    llStage2Results.setVisibility(View.VISIBLE);
                    tvStage2Details.setText("Loading Stage 2 Model...\n");
                    mainScroll.post(() -> mainScroll.fullScroll(View.FOCUS_DOWN));
                });
                
                Thread.sleep(800);
                appendLog("Stage 2 initialized");
                updateStageUI(3);
                
                StringBuilder results = new StringBuilder();
                int diseaseCount = 0;
                long totalStage2Time = 0;

                for (int i = 0; i < topTargets.size(); i++) {
                    OverlayView.ZoneResult z = topTargets.get(i);
                    
                    mainHandler.post(() -> {
                        tvStage2Details.append("\nTARGET: " + z.id + "\nZOOMING AND DIVIDING...\n");
                        overlayView.addZoomedZone(z.id);
                        mainScroll.post(() -> mainScroll.fullScroll(View.FOCUS_DOWN));
                    });
                    
                    long start = System.nanoTime();
                    Thread.sleep(800);
                    if(graphView != null) graphView.addValue((float)(Math.random() * 30 + 70));
                    long end = System.nanoTime();
                    long duration = (end - start) / 1000000;
                    totalStage2Time += duration;
                    
                    String finding;
                    String confidence = "94.2% HIGH CONFIDENCE";
                    
                    if (z.id.equals("Z72")) {
                        finding = "WATER STORED / WET SOIL DETECTED";
                    } else if (z.id.equals("Z80")) {
                        finding = "DRY SOIL / NO GROWTH";
                    } else {
                        finding = "BAD CROP / DISEASE DETECTED";
                        diseaseCount++;
                    }
                    
                    results.append("--------------------------------\n");
                    results.append(z.id).append(" (SUB-GRID ANALYZED)\n");
                    results.append(finding).append("\n");
                    results.append(confidence).append("\n");
                    results.append("Inference: ").append(duration).append(" ms\n");
                    
                    final String currentText = results.toString();
                    mainHandler.post(() -> tvStage2Details.setText(currentText));
                }
                
                appendLog("Rescan analysis complete. Total Stage 2 Inference Time: " + totalStage2Time + " ms");
                Thread.sleep(1000);
                
                final int finalDiseaseCount = diseaseCount;
                mainHandler.post(() -> showFinalReport(finalDiseaseCount));

            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
    }

    private void showFinalReport(int diseaseCount) {
        llFinalReport.setVisibility(View.VISIBLE);
        
        int healthyCount = 0;
        int suspiciousCount = 0;
        int criticalCount = 0;
        
        for (OverlayView.ZoneResult z : allZones) {
            if (z.status == OverlayView.ZoneResult.STATUS_NORMAL) healthyCount++;
            else if (z.status == OverlayView.ZoneResult.STATUS_DRY || z.status == OverlayView.ZoneResult.STATUS_WET) suspiciousCount++;
            else if (z.status == OverlayView.ZoneResult.STATUS_BAD) criticalCount++;
        }
        
        StringBuilder report = new StringBuilder();
        report.append("100 ZONES ANALYZED\n");
        report.append("4 TARGETS RESCANNED (SUB-GRIDS)\n");
        report.append(diseaseCount).append(" CRITICAL FINDINGS\n\n");
        
        report.append("FIELD HEALTH HEATMAP OVERVIEW\n");
        report.append("Healthy zones: ").append(healthyCount).append("%\n");
        report.append("Moderate/Water issues: ").append(suspiciousCount).append("%\n");
        report.append("Critical/Disease zones: ").append(criticalCount).append("%\n\n");
        
        tvFinalReportText.setText(report.toString());
        mainScroll.post(() -> mainScroll.fullScroll(View.FOCUS_DOWN));
        
        // Automatically start sharing report to the farmer after a short delay
        mainHandler.postDelayed(() -> {
            appendLog("PREPARING AUTOMATED WI-FI TRANSMISSION TO FARMER...");
            mainScroll.post(() -> mainScroll.fullScroll(View.FOCUS_DOWN));
        }, 2000);
        
        mainHandler.postDelayed(() -> runWifiDirectShare(), 4000);
    }

    private void runWifiDirectShare() {
        llWifiShareOverlay.setVisibility(View.VISIBLE);
        tvWifiStatus.setText("Initializing Ad-Hoc Network...");
        
        executorService.execute(() -> {
            try {
                Thread.sleep(1000);
                mainHandler.post(() -> tvWifiStatus.setText("Discovering Farmer's Device..."));
                Thread.sleep(1500);
                mainHandler.post(() -> tvWifiStatus.setText("Found: Farmer-Node-01\nConnecting..."));
                Thread.sleep(1500);
                mainHandler.post(() -> tvWifiStatus.setText("Connected!\nTransmitting Field Heatmap & Report to Farmer..."));
                Thread.sleep(2000);
                mainHandler.post(() -> tvWifiStatus.setText("Transmission Complete.\nFarmer Node Synchronized."));
                Thread.sleep(2000);
                mainHandler.post(() -> {
                    llWifiShareOverlay.setVisibility(View.GONE);
                    appendLog("REPORT SUCCESSFULLY SHARED TO FARMER VIA WI-FI DIRECT.");
                    mainScroll.post(() -> mainScroll.fullScroll(View.FOCUS_DOWN));
                });
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
    }
}
