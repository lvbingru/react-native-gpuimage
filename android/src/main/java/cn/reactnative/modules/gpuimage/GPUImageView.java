package cn.reactnative.modules.gpuimage;

import android.content.Context;

import com.facebook.drawee.controller.AbstractDraweeControllerBuilder;
import com.facebook.react.views.image.ReactImageView;

import javax.annotation.Nullable;

/**
 * Created by lvbingru on 6/24/16.
 */
public class GPUImageView extends ReactImageView {
    public GPUImageView(Context context, AbstractDraweeControllerBuilder draweeControllerBuilder, @Nullable Object callerContext) {
        super(context, draweeControllerBuilder, callerContext);
    }
}
