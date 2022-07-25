import React, {Component} from "react";

import {
    HostComponent,
    requireNativeComponent,
    View,
    ViewProps,
} from "react-native";

const RNTSearchVC: HostComponent<ViewProps> =
    requireNativeComponent("RNTSearchVC");

const SearchVCScreen = () => {
    return (
        <View style={{flex: 1}}>
            <RNTSearchVC style={{flex: 1}} />
        </View>
    );
};

export default SearchVCScreen;
