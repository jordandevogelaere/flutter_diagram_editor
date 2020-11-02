import 'package:flutter/material.dart';
import 'package:flutter_provider_canvas/model/item_selected.dart';
import 'package:flutter_provider_canvas/model/link_data.dart';
import 'package:provider/provider.dart';

import 'model/canvas_model.dart';
import 'model/component_data.dart';
import 'model/port_connection.dart';
import 'port.dart';

class Component extends StatelessWidget with ItemSelected {
  @override
  Widget build(BuildContext context) {
    // print('COMPONENT build');
    var canvasPosition = context
        .select<CanvasModel, Offset>((CanvasModel model) => model.position);
    var canvasScale =
        context.select<CanvasModel, double>((CanvasModel model) => model.scale);
    var canvasSelectItem = context
        .select<CanvasModel, dynamic>((CanvasModel model) => model.selectItem);
    var componentData = Provider.of<ComponentData>(context);
    var linkMap = context.select<CanvasModel, Map<int, LinkData>>(
        (CanvasModel model) => model.linkDataMap);

    return Positioned(
      left: canvasScale * componentData.position.dx + canvasPosition.dx,
      top: canvasScale * componentData.position.dy + canvasPosition.dy,
      child: GestureDetector(
        onTap: () {
          print('component tapped: ${componentData.id}');
          canvasSelectItem(componentData);
        },
        onPanUpdate: (details) {
          componentData
              .updateComponentDataPosition(details.delta / canvasScale);

          // TODO: pro každý port posunuté

          componentData.ports.values.forEach((port) {
            port.connections.forEach((connection) {
              if (connection is PortConnectionOut) {
                linkMap[connection.connectionId]
                    .setStart(componentData.getPortCenterPoint(port.id));
              } else if (connection is PortConnectionIn) {
                linkMap[connection.connectionId]
                    .setEnd(componentData.getPortCenterPoint(port.id));
              } else {
                throw ArgumentError('Invalid port connection.');
              }
            });
          });

          // componentData.linksFrom.forEach((linkId) {
          //   linkMap[linkId].updateStart(details.delta / canvasScale);
          // });
          // componentData.linksTo.forEach((linkId) {
          //   linkMap[linkId].updateEnd(details.delta / canvasScale);
          // });
        },
        child: SizedBox(
          width:
              canvasScale * (componentData.size.width + componentData.portSize),
          height: canvasScale *
              (componentData.size.height + componentData.portSize),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // component body:
              Container(
                color: componentData.isItemSelected
                    ? Colors.amber
                    : componentData.color,
                width: canvasScale * componentData.size.width,
                height: canvasScale * componentData.size.height,
                child: Center(
                  child: Text('${componentData.id}'),
                ),
              ),

              ...componentData.ports.values
                  .map((portData) => Port(
                        portData: portData,
                        size: componentData.portSize,
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
