
import React, { Component } from 'react';

import { requireNativeComponent } from 'react-native';

const RNTHomeVC = requireNativeComponent('RNTHomeVC');

const HomeVC = () => {
        return (
            <RNTHomeVC />
        );
}

export default HomeVC