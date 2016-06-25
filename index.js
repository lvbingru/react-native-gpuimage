/**
 * Created by lvbingru on 6/21/16.
 */
// GPUImageView.js

import React, {
  Component,
  PropTypes,
} from 'react';

import {requireNativeComponent, findNodeHandle, Platform, NativeModules, Image} from 'react-native'
const GPUImageViewManager = NativeModules.GPUImageViewManager;

class GPUImageView extends Component {
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
        };
        console.log(nativeProps)
        return <RCTGPUImageView {...nativeProps} />;
      }
      else {
        return null
      }
    }
  }

  async capture() {
    const node = findNodeHandle(this)
    return await GPUImageViewManager.capture(node);
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
    src: true,
    loadingIndicatorSrc: true,
    defaultImageSrc: true,
    imageTag: true,
    progressHandlerRegistered: true,
    shouldNotifyLoadEvents: true,
  }
}

var RCTGPUImageView = requireNativeComponent('RCTGPUImageView', GPUImageView, cfg)


module.exports = GPUImageView;