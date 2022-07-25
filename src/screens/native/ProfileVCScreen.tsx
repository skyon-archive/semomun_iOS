import React, {Component} from "react";

import {
    HostComponent,
    requireNativeComponent,
    View,
    ViewProps,
} from "react-native";

const RNTProfileVC: HostComponent<ViewProps> =
    requireNativeComponent("RNTProfileVC");

const ProfileVCScreen = ({navigation}) => {
    const handleNavigate = e => {
        console.log(e.nativeEvent.navigateTo);
        navigation.navigate(e.nativeEvent.navigateTo);
    };
    return (
        <View style={{flex: 1}}>
            <RNTProfileVC style={{flex: 1}} onNavigate={handleNavigate} />
        </View>
    );
};

export default ProfileVCScreen;
