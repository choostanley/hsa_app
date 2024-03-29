import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'bluetooth_services_widget.dart';

class DeviceServicesPage extends StatefulWidget {
  const DeviceServicesPage({super.key, required this.bluetoothDevice});

  final BluetoothDevice bluetoothDevice;

  @override
  State<StatefulWidget> createState() {
    return DeviceServicesState();
  }
}

class DeviceServicesState extends State<DeviceServicesPage> {
  @override
  Widget build(BuildContext context) {
    const appbarHeight = 56.0;
    final height = max(
        0.0, (MediaQuery.maybeOf(context)?.size.height ?? 0.0) - appbarHeight);
    final itemHeight = height / 2.0;

    return Scaffold(
        appBar: AppBar(
          title: SelectableText(widget.bluetoothDevice.name ?? 'No name set'),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                    constraints: BoxConstraints(minHeight: itemHeight),
                    child: BluetoothServicesWidget(
                        widget.bluetoothDevice, itemHeight))
              ],
            )));
  }
}
