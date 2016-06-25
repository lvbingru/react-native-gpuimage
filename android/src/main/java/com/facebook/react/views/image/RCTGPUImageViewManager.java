package com.facebook.react.views.image;

import android.graphics.Color;
import android.graphics.PorterDuff;

import com.facebook.csslayout.CSSConstants;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.AbstractDraweeControllerBuilder;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.PixelUtil;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewProps;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.annotations.ReactPropGroup;

import java.util.Map;

import javax.annotation.Nullable;

/**
 * Created by lvbingru on 6/24/16.
 */
public class RCTGPUImageViewManager extends SimpleViewManager<RCTGPUImageView> {

    public static final String REACT_CLASS = "RCTGPUImageView";

    private ResourceDrawableIdHelper mResourceDrawableIdHelper;
    private @Nullable AbstractDraweeControllerBuilder mDraweeControllerBuilder;
    private final @Nullable Object mCallerContext;

    public RCTGPUImageViewManager(
            AbstractDraweeControllerBuilder draweeControllerBuilder,
            Object callerContext) {
        mDraweeControllerBuilder = draweeControllerBuilder;
        mCallerContext = callerContext;
        mResourceDrawableIdHelper = new ResourceDrawableIdHelper();
    }

    public RCTGPUImageViewManager() {
        // Lazily initialize as FrescoModule have not been initialized yet
        mDraweeControllerBuilder = null;
        mCallerContext = null;
        mResourceDrawableIdHelper = new ResourceDrawableIdHelper();
    }

    public AbstractDraweeControllerBuilder getDraweeControllerBuilder() {
        if (mDraweeControllerBuilder == null) {
            mDraweeControllerBuilder = Fresco.newDraweeControllerBuilder();
        }
        return mDraweeControllerBuilder;
    }

    public Object getCallerContext() {
        return mCallerContext;
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }


    @Override
    public RCTGPUImageView createViewInstance(ThemedReactContext context) {
        return new RCTGPUImageView(
                context,
                getDraweeControllerBuilder(),
                getCallerContext());
    }


    @ReactProp(name = "filters")
    public void setFilters(RCTGPUImageView view, @Nullable ReadableArray filters) {
        view.setFilters(filters);
    }

    // In JS this is Image.props.source.uri
    @ReactProp(name = "src")
    public void setSource(RCTGPUImageView view, @Nullable String source) {
        view.setSource(source, mResourceDrawableIdHelper);
    }

    // In JS this is Image.props.loadingIndicatorSource.uri
    @ReactProp(name = "loadingIndicatorSrc")
    public void setLoadingIndicatorSource(RCTGPUImageView view, @Nullable String source) {
        view.setLoadingIndicatorSource(source, mResourceDrawableIdHelper);
    }

    @ReactProp(name = "borderColor", customType = "Color")
    public void setBorderColor(RCTGPUImageView view, @Nullable Integer borderColor) {
        if (borderColor == null) {
            view.setBorderColor(Color.TRANSPARENT);
        } else {
            view.setBorderColor(borderColor);
        }
    }

    @ReactProp(name = "overlayColor")
    public void setOverlayColor(RCTGPUImageView view, @Nullable Integer overlayColor) {
        if (overlayColor == null) {
            view.setOverlayColor(Color.TRANSPARENT);
        } else {
            view.setOverlayColor(overlayColor);
        }
    }

    @ReactProp(name = "borderWidth")
    public void setBorderWidth(RCTGPUImageView view, float borderWidth) {
        view.setBorderWidth(borderWidth);
    }

    @ReactPropGroup(names = {
            ViewProps.BORDER_RADIUS,
            ViewProps.BORDER_TOP_LEFT_RADIUS,
            ViewProps.BORDER_TOP_RIGHT_RADIUS,
            ViewProps.BORDER_BOTTOM_RIGHT_RADIUS,
            ViewProps.BORDER_BOTTOM_LEFT_RADIUS
    }, defaultFloat = CSSConstants.UNDEFINED)
    public void setBorderRadius(RCTGPUImageView view, int index, float borderRadius) {
        if (!CSSConstants.isUndefined(borderRadius)) {
            borderRadius = PixelUtil.toPixelFromDIP(borderRadius);
        }

        if (index == 0) {
            view.setBorderRadius(borderRadius);
        } else {
            view.setBorderRadius(borderRadius, index - 1);
        }
    }

    @ReactProp(name = ViewProps.RESIZE_MODE)
    public void setResizeMode(RCTGPUImageView view, @Nullable String resizeMode) {
        view.setScaleType(ImageResizeMode.toScaleType(resizeMode));
    }

    @ReactProp(name = "tintColor", customType = "Color")
    public void setTintColor(RCTGPUImageView view, @Nullable Integer tintColor) {
        if (tintColor == null) {
            view.clearColorFilter();
        } else {
            view.setColorFilter(tintColor, PorterDuff.Mode.SRC_IN);
        }
    }

    @ReactProp(name = "progressiveRenderingEnabled")
    public void setProgressiveRenderingEnabled(RCTGPUImageView view, boolean enabled) {
        view.setProgressiveRenderingEnabled(enabled);
    }

    @ReactProp(name = "fadeDuration")
    public void setFadeDuration(RCTGPUImageView view, int durationMs) {
        view.setFadeDuration(durationMs);
    }

    @ReactProp(name = "shouldNotifyLoadEvents")
    public void setLoadHandlersRegistered(RCTGPUImageView view, boolean shouldNotifyLoadEvents) {
        view.setShouldNotifyLoadEvents(shouldNotifyLoadEvents);
    }

    @Override
    public @Nullable Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.of(
                ImageLoadEvent.eventNameForType(ImageLoadEvent.ON_LOAD_START),
                MapBuilder.of("registrationName", "onLoadStart"),
                ImageLoadEvent.eventNameForType(ImageLoadEvent.ON_LOAD),
                MapBuilder.of("registrationName", "onLoad"),
                ImageLoadEvent.eventNameForType(ImageLoadEvent.ON_LOAD_END),
                MapBuilder.of("registrationName", "onLoadEnd")
        );
    }

    @Override
    protected void onAfterUpdateTransaction(RCTGPUImageView view) {
        super.onAfterUpdateTransaction(view);
        view.maybeUpdateView();
    }
}
