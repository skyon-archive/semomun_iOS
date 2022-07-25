import {createNativeStackNavigator} from "@react-navigation/native-stack";
import LoginSelectVCScreen from "screens/native/LoginSelectVCScreen";
import BottomTabNavigator from "navigations/BottomTabNavigator";
import React from "react";

export type RootParamList = {
    Root: undefined;
    Login: undefined;
};

const Stack = createNativeStackNavigator<RootParamList>();

const RootNavigator = () => {
    return (
        <Stack.Navigator screenOptions={{headerShown: false}}>
            <Stack.Screen name="Root" component={BottomTabNavigator} />
            <Stack.Group screenOptions={{presentation: "modal"}}>
                <Stack.Screen name="Login" component={LoginSelectVCScreen} />
            </Stack.Group>
        </Stack.Navigator>
    );
};

export default RootNavigator;
