import {createNativeStackNavigator} from "@react-navigation/native-stack";
import HomeVC from "screens/native/HomeVCScreen";
import React from "react";

const Stack = createNativeStackNavigator();

const HomeStackNavigator = () => {
    return (
        <Stack.Navigator>
            <Stack.Screen
                name="Home"
                component={HomeVC}
                options={{headerShown: false}}
            />
        </Stack.Navigator>
    );
};

export default HomeStackNavigator;
