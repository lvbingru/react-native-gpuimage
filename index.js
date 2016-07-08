/**
 * Created by lvbingru on 6/21/16.
 */
// GPUImageView.js

import React, {
  Component,
  PropTypes,
} from 'react';

import {
  requireNativeComponent, Platform, NativeModules, Image,
  UIManager,
  findNodeHandle,
} from 'react-native'
const GPUImageViewManager = NativeModules.GPUImageViewManager;

class GPUImageView extends Component {
  onCaptureDone = (ev) => {
    const capturing = this.capturing;
    this.capturing = null;
    capturing && capturing.resolve(ev.nativeEvent);
  };
  onCaptureFailed = ev => {
    const capturing = this.capturing;
    this.capturing = null;
    capturing && capturing.reject(new Error(ev.nativeEvent.message));
  };
  render() {
    if (Platform.OS === 'ios') {
      return <RCTGPUImageView {...this.props} />;
    }
    else {
      var source = this.props.source;
      var loadingIndicatorSource = this.props.loadingIndicatorSource;

      // As opposed to the ios version, here it render `null`
      // when no source or source.uri... so let's not break that.

      if (source && source.uri === '') {
        console.warn('source.uri should not be an empty string');
      }

      if (source && source.uri) {
        var style = this.props.style;
        var {onLoadStart, onLoad, onLoadEnd} = this.props;

        var nativeProps = {...this.props,
          style,
          shouldNotifyLoadEvents: !!(onLoadStart || onLoad || onLoadEnd),
          src: source.uri,
          loadingIndicatorSrc: loadingIndicatorSource ? loadingIndicatorSource.uri : null,
          onCaptureDone: this.onCaptureDone,
          onCaptureFailed: this.onCaptureFailed,
        };
        return <RCTGPUImageView {...nativeProps} />;
      }
      else {
        return null
      }
    }
  }

  capture() {
    if (Platform.OS === 'ios'){
      return GPUImageViewManager.capture(findNodeHandle(this));
    }
    if (this.capturing) {
      return Promise.reject('isCapturing');
    }
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RCTGPUImageView.Commands.capture,
      null
    );
    return new Promise((resolve, reject)=>{
      this.capturing = {resolve, reject};
    });
  }
}

GPUImageView.propTypes = {
  filters: PropTypes.array,
  ...Image.propTypes,
};

var cfg = {
  nativeOnly: {
  },
};

if (Platform.OS === 'android') {
  cfg.nativeOnly = {
    ...cfg.nativeOnly,
    src: true,
    loadingIndicatorSrc: true,
    defaultImageSrc: true,
    imageTag: true,
    progressHandlerRegistered: true,
    shouldNotifyLoadEvents: true,
    onCaptureDone: true,
    onCaptureFailed: true,
  }
}

var RCTGPUImageView = requireNativeComponent('RCTGPUImageView', GPUImageView, cfg)


module.exports = GPUImageView;