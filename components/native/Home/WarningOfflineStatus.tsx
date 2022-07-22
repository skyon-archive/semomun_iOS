
import React, { Component } from 'react';

import { requireNativeComponent } from 'react-native';

const NativeWarningOfflineStatusView = requireNativeComponent('WarningOfflineStatusView');

const WarningOfflineStatus = () => {
        return (
            <NativeWarningOfflineStatusView/>
        );
}

export default WarningOfflineStatus