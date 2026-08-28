package com.example.edge_ai;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

public class OverlayView extends View {
    private Paint gridPaint;
    private Paint subGridPaint;
    private Paint textPaint;
    private Paint normalPaint;
    private Paint dryPaint;
    private Paint badPaint;
    private Paint wetPaint;
    
    private List<ZoneResult> results = new ArrayList<>();
    private List<String> zoomedZones = new ArrayList<>();
    
    public OverlayView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
        generateRandomHeatmap();
    }
    
    private void init() {
        gridPaint = new Paint();
        gridPaint.setColor(Color.argb(40, 255, 255, 255));
        gridPaint.setStyle(Paint.Style.STROKE);
        gridPaint.setStrokeWidth(1f);

        subGridPaint = new Paint();
        subGridPaint.setColor(Color.argb(255, 255, 255, 0));
        subGridPaint.setStyle(Paint.Style.STROKE);
        subGridPaint.setStrokeWidth(4f);
        
        textPaint = new Paint();
        textPaint.setColor(Color.WHITE);
        textPaint.setTextSize(20f);
        textPaint.setTextAlign(Paint.Align.CENTER);
        textPaint.setShadowLayer(4f, 0f, 0f, Color.BLACK);
        
        normalPaint = new Paint();
        normalPaint.setColor(Color.argb(100, 0, 200, 0)); // Green
        normalPaint.setStyle(Paint.Style.FILL);
        
        dryPaint = new Paint();
        dryPaint.setColor(Color.argb(160, 255, 120, 0)); // Orange
        dryPaint.setStyle(Paint.Style.FILL);
        
        badPaint = new Paint();
        badPaint.setColor(Color.argb(160, 255, 0, 0)); // Red
        badPaint.setStyle(Paint.Style.FILL);

        wetPaint = new Paint();
        wetPaint.setColor(Color.argb(160, 0, 200, 255)); // Cyan
        wetPaint.setStyle(Paint.Style.FILL);
    }
    
    public void generateRandomHeatmap() {
        results.clear();
        List<Integer> badCropZones = Arrays.asList(11, 12, 13, 23, 33, 32, 31, 21, 65, 66, 57, 75, 76, 77, 85, 86, 87, 28, 38);
        List<Integer> wetZones = Arrays.asList(72);
        List<Integer> dryZones = Arrays.asList(50, 60, 70, 80, 79, 89);

        for (int r = 0; r < 10; r++) {
            for (int c = 0; c < 10; c++) {
                int zoneNum = r * 10 + c + 1;
                String zoneId = String.format(Locale.US, "Z%02d", zoneNum);
                int score = (int)(Math.random() * 20);
                int status = ZoneResult.STATUS_NORMAL;
                
                // Add jitter to create a random pre-scan heatmap look
                if (badCropZones.contains(zoneNum)) {
                    status = ZoneResult.STATUS_BAD;
                    score = 75 + (int)(Math.random() * 20);
                } else if (wetZones.contains(zoneNum)) {
                    status = ZoneResult.STATUS_WET;
                    score = 60 + (int)(Math.random() * 20);
                } else if (dryZones.contains(zoneNum)) {
                    status = ZoneResult.STATUS_DRY;
                    score = 65 + (int)(Math.random() * 20);
                } else {
                    if (Math.random() > 0.8) {
                        status = ZoneResult.STATUS_DRY;
                        score = 40 + (int)(Math.random() * 20);
                    }
                }
                results.add(new ZoneResult(zoneId, r, c, status, score));
            }
        }
        invalidate();
    }
    
    public void setResults(List<ZoneResult> results) {
        this.results = results;
        invalidate();
    }
    
    public List<ZoneResult> getResults() {
        return results;
    }

    public void addZoomedZone(String zoneId) {
        if (!zoomedZones.contains(zoneId)) {
            zoomedZones.add(zoneId);
            invalidate();
        }
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(Canvas.class.cast(canvas));
        
        int width = getWidth();
        int height = getHeight();
        if (width == 0 || height == 0) return;
        
        int cols = 10;
        int rows = 10;
        
        float cellWidth = (float) width / cols;
        float cellHeight = (float) height / rows;
        
        for (ZoneResult r : results) {
            float left = r.col * cellWidth;
            float top = r.row * cellHeight;
            float right = left + cellWidth;
            float bottom = top + cellHeight;
            
            if (r.status == ZoneResult.STATUS_NORMAL) {
                canvas.drawRect(left, top, right, bottom, normalPaint);
            } else if (r.status == ZoneResult.STATUS_DRY) {
                canvas.drawRect(left, top, right, bottom, dryPaint);
            } else if (r.status == ZoneResult.STATUS_BAD) {
                canvas.drawRect(left, top, right, bottom, badPaint);
            } else if (r.status == ZoneResult.STATUS_WET) {
                canvas.drawRect(left, top, right, bottom, wetPaint);
            }
            
            // Draw subtle grid
            canvas.drawRect(left, top, right, bottom, gridPaint);
            
            // Text for zone
            float cx = left + cellWidth / 2;
            float cy = top + cellHeight / 2 + textPaint.getTextSize() / 3;
            // Only draw text if not too crowded or if it's a key zone
            if (r.score > 60 || r.status != ZoneResult.STATUS_NORMAL) {
                canvas.drawText(r.id, cx, cy, textPaint);
            }

            // Draw sub-grid if this zone is zoomed
            if (zoomedZones.contains(r.id)) {
                canvas.drawLine(left + cellWidth/2, top, left + cellWidth/2, bottom, subGridPaint);
                canvas.drawLine(left, top + cellHeight/2, right, top + cellHeight/2, subGridPaint);
                canvas.drawRect(left, top, right, bottom, subGridPaint);
            }
        }
    }
    
    public static class ZoneResult {
        public static final int STATUS_NORMAL = 0;
        public static final int STATUS_DRY = 1;
        public static final int STATUS_BAD = 2;
        public static final int STATUS_WET = 3;
        
        public String id;
        public int row;
        public int col;
        public int status;
        public float score;
        
        public ZoneResult(String id, int row, int col, int status, float score) {
            this.id = id;
            this.row = row;
            this.col = col;
            this.status = status;
            this.score = score;
        }
    }
}
