import React, {Component} from "react";

import {
    HostComponent,
    requireNativeComponent,
    View,
    ViewProps,
} from "react-native";

const RNTHomeVC: HostComponent<ViewProps> = requireNativeComponent("RNTHomeVC");

const HomeVCScreen = () => {
    return (
        <View style={{flex: 1}}>
            <RNTHomeVC style={{flex: 1}} />
        </View>
    );
};

export default HomeVCScreen;
