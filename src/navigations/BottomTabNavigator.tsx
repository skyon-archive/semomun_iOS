import {createBottomTabNavigator} from "@react-navigation/bottom-tabs";
import {createNativeStackNavigator} from "@react-navigation/native-stack";
import BookshelfVCScreen from "screens/native/BookshelfVCScreen";
import HomeVCScreen from "screens/native/HomeVCScreen";
import ProfileVCScreen from "screens/native/ProfileVCScreen";
import SearchVCScreen from "screens/native/SearchVCScreen";
import HomeStackNavigator from "navigations/HomeStackNavigator";
import React from "react";
import {
    BookmarkAltIcon,
    DotsHorizontalIcon,
    HomeIcon,
    SearchIcon,
} from "react-native-heroicons/solid";
import TestScreen from "screens/Test/TestScreen";

const BottomTab = createBottomTabNavigator();

const BottomTabNavigator = () => {
    return (
        <BottomTab.Navigator
            initialRouteName="Home"
            screenOptions={{headerShown: false}}>
            <BottomTab.Screen
                name="HomeTab"
                component={HomeStackNavigator}
                options={{
                    tabBarLabel: "홈",
                    tabBarIcon: () => <HomeIcon />,
                }}
            />
            <BottomTab.Screen
                name="Search"
                component={SearchVCScreen}
                options={{
                    tabBarLabel: "검색",
                    tabBarIcon: () => <SearchIcon />,
                }}
            />
            <BottomTab.Screen
                name="Bookshelf"
                component={BookshelfVCScreen}
                options={{
                    tabBarLabel: "책장",
                    tabBarIcon: () => <BookmarkAltIcon />,
                }}
            />
            <BottomTab.Screen
                name="Profile"
                component={ProfileVCScreen}
                options={{
                    tabBarLabel: "더 보기",
                    tabBarIcon: () => <DotsHorizontalIcon />,
                }}
            />

            <BottomTab.Screen
                name="Test"
                component={TestScreen}
                options={{
                    tabBarLabel: "Test",
                    tabBarIcon: () => <DotsHorizontalIcon />,
                }}
            />
        </BottomTab.Navigator>
    );
};

export default BottomTabNavigator;
