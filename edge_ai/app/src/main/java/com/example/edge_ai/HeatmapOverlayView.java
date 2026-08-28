package com.example.edge_ai;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.Shader;
import android.util.AttributeSet;
import android.view.View;
import java.util.ArrayList;
import java.util.List;

public class HeatmapOverlayView extends View {
    private List<OverlayView.ZoneResult> results = new ArrayList<>();
    private Paint gradientPaint;

    public HeatmapOverlayView(Context context, AttributeSet attrs) {
        super(context, attrs);
        gradientPaint = new Paint();
    }

    public void setResults(List<OverlayView.ZoneResult> results) {
        this.results = results;
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        int width = getWidth();
        int height = getHeight();
        if (width == 0 || height == 0 || results == null || results.isEmpty()) return;
        
        int cols = 10;
        int rows = 10;
        
        float cellWidth = (float) width / cols;
        float cellHeight = (float) height / rows;
        float radius = cellWidth * 1.8f; // Large overlap for smooth blending
        
        for (OverlayView.ZoneResult r : results) {
            float cx = r.col * cellWidth + cellWidth / 2f;
            float cy = r.row * cellHeight + cellHeight / 2f;
            
            int centerColor = Color.TRANSPARENT;
            if (r.status == OverlayView.ZoneResult.STATUS_NORMAL) {
                centerColor = Color.argb(160, 0, 200, 255); // Vivid cool blue-green
            } else if (r.status == OverlayView.ZoneResult.STATUS_WET) {
                centerColor = Color.argb(200, 0, 50, 255); // Solid deep blue
            } else if (r.status == OverlayView.ZoneResult.STATUS_DRY) {
                centerColor = Color.argb(180, 255, 180, 0); // Vibrant orange
            } else if (r.status == OverlayView.ZoneResult.STATUS_BAD) {
                centerColor = Color.argb(220, 255, 0, 0); // Intense hot red
            }
            
            RadialGradient gradient = new RadialGradient(
                cx, cy, radius, centerColor, Color.TRANSPARENT, Shader.TileMode.CLAMP
            );
            gradientPaint.setShader(gradient);
            canvas.drawCircle(cx, cy, radius, gradientPaint);
        }
    }
}
