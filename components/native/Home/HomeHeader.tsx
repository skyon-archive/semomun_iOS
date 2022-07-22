
import React, { Component } from 'react';

import { requireNativeComponent } from 'react-native';

const NativeHomeHeaderView = requireNativeComponent('HomeHeaderView');

const HomeHeader = () => {
        return (
            <NativeHomeHeaderView/>
        );
}

export default HomeHeader