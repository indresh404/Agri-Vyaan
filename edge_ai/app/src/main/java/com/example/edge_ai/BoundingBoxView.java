package com.example.edge_ai;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

import org.tensorflow.lite.task.vision.detector.Detection;

import java.util.ArrayList;
import java.util.List;

public class BoundingBoxView extends View {
    private Paint boxPaint;
    private Paint textPaint;
    private Paint textBackgroundPaint;
    private List<Detection> detections = new ArrayList<>();

    public BoundingBoxView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        boxPaint = new Paint();
        boxPaint.setColor(Color.GREEN);
        boxPaint.setStyle(Paint.Style.STROKE);
        boxPaint.setStrokeWidth(5f);

        textPaint = new Paint();
        textPaint.setColor(Color.WHITE);
        textPaint.setTextSize(30f);

        textBackgroundPaint = new Paint();
        textBackgroundPaint.setColor(Color.GREEN);
        textBackgroundPaint.setStyle(Paint.Style.FILL);
    }

    public void setDetections(List<Detection> detections) {
        this.detections = detections;
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        if (detections == null || detections.isEmpty()) return;

        for (Detection detection : detections) {
            RectF box = detection.getBoundingBox();
            
            // The detections are based on the bitmap size (640x480).
            // We need to scale them to the size of this view.
            // Since TextureView scales to fit, we'll map assuming center-crop or fit-xy.
            // For simplicity, assuming the Bitmap was 640x480.
            float scaleX = (float) getWidth() / 640f;
            float scaleY = (float) getHeight() / 480f;

            float left = box.left * scaleX;
            float top = box.top * scaleY;
            float right = box.right * scaleX;
            float bottom = box.bottom * scaleY;

            canvas.drawRect(left, top, right, bottom, boxPaint);

            if (detection.getCategories() != null && !detection.getCategories().isEmpty()) {
                String label = detection.getCategories().get(0).getLabel();
                float score = detection.getCategories().get(0).getScore() * 100f;
                String text = String.format("%s %.1f%%", label, score);
                
                // Draw background for text
                float textWidth = textPaint.measureText(text);
                canvas.drawRect(left, top - 40, left + textWidth + 10, top, textBackgroundPaint);
                
                // Draw text
                canvas.drawText(text, left + 5, top - 10, textPaint);
            }
        }
    }
}
