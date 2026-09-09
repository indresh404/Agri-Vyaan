package com.example.edge_ai;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.View;

import java.util.LinkedList;

public class GraphView extends View {
    private Paint linePaint;
    private Paint fillPaint;
    private Paint gridPaint;
    private LinkedList<Float> values = new LinkedList<>();
    private final int MAX_POINTS = 50;

    public GraphView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        linePaint = new Paint();
        linePaint.setColor(Color.parseColor("#00FF00"));
        linePaint.setStyle(Paint.Style.STROKE);
        linePaint.setStrokeWidth(3f);
        linePaint.setAntiAlias(true);

        fillPaint = new Paint();
        fillPaint.setColor(Color.parseColor("#3300FF00"));
        fillPaint.setStyle(Paint.Style.FILL);

        gridPaint = new Paint();
        gridPaint.setColor(Color.parseColor("#44FFFFFF"));
        gridPaint.setStyle(Paint.Style.STROKE);
        gridPaint.setStrokeWidth(1f);

        for(int i = 0; i < MAX_POINTS; i++) {
            values.add(0f);
        }
    }

    public void addValue(float val) {
        values.removeFirst();
        values.add(val);
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        float width = getWidth();
        float height = getHeight();
        float stepX = width / (MAX_POINTS - 1);

        // Draw basic grid
        canvas.drawLine(0, height/2, width, height/2, gridPaint);
        canvas.drawLine(0, height, width, height, gridPaint);

        Path path = new Path();
        Path fillPath = new Path();
        fillPath.moveTo(0, height);

        for(int i = 0; i < values.size(); i++) {
            float x = i * stepX;
            // Map value (0-100) to height
            float y = height - (values.get(i) / 100f * height);
            
            if(i == 0) {
                path.moveTo(x, y);
                fillPath.lineTo(x, y);
            } else {
                path.lineTo(x, y);
                fillPath.lineTo(x, y);
            }
        }
        
        fillPath.lineTo(width, height);
        fillPath.close();

        canvas.drawPath(fillPath, fillPaint);
        canvas.drawPath(path, linePaint);
    }
}
