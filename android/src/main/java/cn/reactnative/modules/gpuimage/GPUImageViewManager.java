package cn.reactnative.modules.gpuimage;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.AbstractDraweeControllerBuilder;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.views.image.ReactImageView;

import javax.annotation.Nullable;

/**
 * Created by lvbingru on 6/24/16.
 */
public class GPUImageViewManager extends SimpleViewManager<GPUImageView> {

    public static final String REACT_CLASS = "RCTGPUImageView";

//    private ResourceDrawableIdHelper mResourceDrawableIdHelper;
    private @Nullable
    AbstractDraweeControllerBuilder mDraweeControllerBuilder;
    private final @Nullable Object mCallerContext;

    public GPUImageViewManager(
            AbstractDraweeControllerBuilder draweeControllerBuilder,
            Object callerContext) {
        mDraweeControllerBuilder = draweeControllerBuilder;
        mCallerContext = callerContext;
//        mResourceDrawableIdHelper = new ResourceDrawableIdHelper();
    }

    public GPUImageViewManager() {
        // Lazily initialize as FrescoModule have not been initialized yet
        mDraweeControllerBuilder = null;
        mCallerContext = null;
//        mResourceDrawableIdHelper = new ResourceDrawableIdHelper();
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected GPUImageView createViewInstance(ThemedReactContext reactContext) {
        return new GPUImageView(reactContext, Fresco.newDraweeControllerBuilder(), mCallerContext);
    }

    @ReactProp(name = "filters")
    public void setFilters(ReactImageView view, @Nullable ReadableArray filters) {

    }
}
