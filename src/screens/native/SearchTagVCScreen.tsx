import React, {Component} from "react";

import {
    HostComponent,
    requireNativeComponent,
    View,
    ViewProps,
} from "react-native";

const RNTSearchTagVC: HostComponent<ViewProps> =
    requireNativeComponent("RNTSearchTagVC");

const SearchTagVCScreen = () => {
    return (
        <View style={{flex: 1}}>
            <RNTSearchTagVC style={{flex: 1}} />
        </View>
    );
};

export default SearchTagVCScreen;
