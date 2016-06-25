package com.facebook.react.views.image;

import android.content.Context;

import com.facebook.drawee.controller.AbstractDraweeControllerBuilder;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;

import java.lang.reflect.Field;

import javax.annotation.Nullable;

import jp.co.cyberagent.android.gpuimage.GPUImageFilter;
import jp.co.cyberagent.android.gpuimage.GPUImageFilterGroup;
import jp.co.cyberagent.android.gpuimage.GPUImageView;

/**
 * Created by lvbingru on 6/24/16.
 */
public class RCTGPUImageView extends ReactImageView {
    public RCTGPUImageView(Context context, AbstractDraweeControllerBuilder draweeControllerBuilder, @Nullable Object callerContext) {
        super(context, draweeControllerBuilder, callerContext);

        mGPUImageView = new GPUImageView(context);

    }

    ReadableArray mFilters;
    GPUImageFilterGroup mFilterGroup;
    GPUImageView mGPUImageView;

    public void setFilters(ReadableArray filters) {
        mFilters = filters;
        boolean needUpdate = false;
        int count = filters.size();
        if (mFilterGroup==null || mFilterGroup.getFilters().size() != count) {
            needUpdate = true;
        }
        else {
            for (int i = 0 ;i<count; i++) {
                ReadableMap filterMap = filters.getMap(i);
                String name = filterMap.getString("name");
                GPUImageFilter filter = mFilterGroup.getFilters().get(i);
                if (!filter.getClass().getName().equals(name)) {
                    needUpdate = true;
                    break;
                }

            }
        }

        if (needUpdate) {
            mFilterGroup = new GPUImageFilterGroup();
            for (int i = 0; i<count; i++) {
                ReadableMap filterMap = filters.getMap(i);
                String name = filterMap.getString("name");
                if (name != null) {
                    try {
                        Class c = Class.forName("jp.co.cyberagent.android.gpuimage."+name);
                        GPUImageFilter imageFilter;
                        if (name.startsWith("IF")) {
                            Class[] cArg = new Class[1];
                            cArg[0] = Context.class;
                            imageFilter = (GPUImageFilter) c.getDeclaredConstructor(cArg).newInstance(getContext());
                        }
                        else {
                            imageFilter = (GPUImageFilter) c.newInstance();
                        }
                        mFilterGroup.addFilter(imageFilter);
                    } catch (Exception e) {
                        GPUImageFilter imageFilter = new GPUImageFilter();
                        mFilterGroup.addFilter(imageFilter);
                    }
                }
            }
        }

        for (int i = 0 ; i<count ; i++) {
            ReadableMap filterMap = filters.getMap(i);
            if (filterMap.hasKey("params")) {
                ReadableMap params = filterMap.getMap("params");
                GPUImageFilter filter = mFilterGroup.getFilters().get(i);
                ReadableMapKeySetIterator interator = params.keySetIterator();
                while (interator.hasNextKey()) {
                    String key = interator.nextKey();
                    try {
                        Field field = filter.getClass().getDeclaredField(key);
                        ReadableType type = params.getType(key);
                        if (type == ReadableType.Number) {
                            double number = params.getDouble(key);
                            field.setDouble(filter, number);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                }
            }
        }
        this.updateGPUImage();
    }

    private void updateGPUImage() {
        if (mFilterGroup!=null) {
            mGPUImageView.setFilter(mFilterGroup);
            mGPUImageView.requestRender();
        }
    }
}
