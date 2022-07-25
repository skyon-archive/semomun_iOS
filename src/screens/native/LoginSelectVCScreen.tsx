import {NativeStackScreenProps} from "@react-navigation/native-stack";
import {RootParamList} from "navigations/RootNavigator";
import React, {Component} from "react";

import {
    HostComponent,
    requireNativeComponent,
    View,
    ViewProps,
} from "react-native";

const RNTLoginSelectVC: HostComponent<ViewProps> =
    requireNativeComponent("RNTLoginSelectVC");

const LoginSelectVCScreen = ({}: NativeStackScreenProps<RootParamList>) => {
    return (
        <View style={{flex: 1}}>
            <RNTLoginSelectVC style={{flex: 1}} />
        </View>
    );
};

export default LoginSelectVCScreen;
