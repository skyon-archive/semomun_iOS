import React, {Component} from "react";

import {
    HostComponent,
    requireNativeComponent,
    View,
    ViewProps,
} from "react-native";

const RNTBookshelfVC: HostComponent<ViewProps> =
    requireNativeComponent("RNTBookshelfVC");

const BookshelfVCScreen = () => {
    return (
        <View style={{flex: 1}}>
            <RNTBookshelfVC style={{flex: 1}} />
        </View>
    );
};

export default BookshelfVCScreen;
