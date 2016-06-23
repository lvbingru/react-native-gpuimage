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
    if (Platform.OS === 'android') {
      return <Image {...this.props}/>
    }
    else {
      return <RCTGPUImageView {...this.props} />;
    }
  }

  async capture() {
    const node = findNodeHandle(this)
    return await GPUImageViewManager.capture(node);
  }
}

GPUImageView.propTypes = {
  filter: PropTypes.object,
  ...Image.propTypes,
};

var RCTGPUImageView = requireNativeComponent('RCTGPUImageView', GPUImageView)

module.exports = GPUImageView;