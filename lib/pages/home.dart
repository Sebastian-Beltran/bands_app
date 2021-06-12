import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Band Names ${socketService.serverStatus}',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10),
              child: socketService.serverStatus == ServerStatus.Online
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.blue[300],
                    )
                  : Icon(
                      Icons.offline_bolt,
                      color: Colors.red,
                    ))
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, i) => bandTile(bands[i])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        socketService.emit('delete-band', {'id': band.id});
      },
      background: Container(
        padding: const EdgeInsets.only(left: 10),
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete Band',
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 1)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.socket.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (!Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('New Band name:'),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                    child: Text('Add'),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () {
                      addBandToList(textController.text);
                    })
              ],
            );
          });
    }

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('New Band name:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                  child: Text('Add'),
                  isDefaultAction: true,
                  onPressed: () {
                    addBandToList(textController.text);
                  }),
              CupertinoDialogAction(
                  child: Text('Dismiss'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1) {
      //Podemos agregar
      //emitir el evento add-band
      socketService.socket.emit('add-band', {'name': name});
      print(name);
      //{name: name}

    }
    Navigator.pop(context);
  }

  _showGraph() {
    Map<String, double> dataMap = Map();
      // "Flutter": 5,
      bands.forEach((band) { 
        dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
      });
    
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(microseconds: 800),
        chartValuesOptions: ChartValuesOptions(
          decimalPlaces: 0,
          showChartValueBackground: false
        ),
        chartType: ChartType.ring,
      ),
    );
  }
}
