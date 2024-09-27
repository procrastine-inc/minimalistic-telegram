import { Colors } from "@/constants/Colors";
import { useColorScheme } from "@/hooks/useColorScheme";
import { Drawer } from "expo-router/drawer";
import { GestureHandlerRootView } from "react-native-gesture-handler";

export default function Layout() {
  const colorScheme = useColorScheme();
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <Drawer>
        <Drawer.Screen
          name="index"
          options={{
            drawerLabel: () => null,
            headerStyle: {
              backgroundColor: Colors[colorScheme ?? "light"].tabIconSelected,
            },
            headerTintColor: "#fff",
            drawerItemStyle: {
              display: "none",
            },
            title: "Home",
          }}
        />
      </Drawer>
    </GestureHandlerRootView>
  );
}
