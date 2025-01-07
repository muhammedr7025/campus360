import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';

class IoTControlPage extends StatefulWidget {
  @override
  State<IoTControlPage> createState() => _IoTControlPageState();
}

class _IoTControlPageState extends State<IoTControlPage> {
  Future<List<Map<String, dynamic>>> fetchClasses() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> classes = [];

    try {
      // Get all departments
      QuerySnapshot departmentsSnapshot =
          await firestore.collection('departments').get();

      for (var department in departmentsSnapshot.docs) {
        // Get all batches for this department
        QuerySnapshot batchesSnapshot =
            await department.reference.collection('batches').get();

        for (var batch in batchesSnapshot.docs) {
          // Get all classes for this batch
          QuerySnapshot classesSnapshot =
              await batch.reference.collection('classes').get();

          for (var classDoc in classesSnapshot.docs) {
            Map<String, dynamic> data = classDoc.data() as Map<String, dynamic>;
            classes.add({
              'id': classDoc.id,
              'name': data['name'] ?? 'Unnamed Class',
              'department': department.id,
              'batch': batch.id,
              'imageUrl': data['imageUrl'] ?? '',
              'staff_advisor': data['staff_advisor'] ?? 'N/A',
              'student_rep': data['student_rep'] ?? 'N/A',
              'devices': data['devices'] ?? {},
            });
          }
        }
      }
      return classes;
    } catch (e) {
      print('Error fetching classes: $e');
      rethrow; // This will help show the error in the FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IoT Control - Admin Dashboard'),
        backgroundColor: primaryColor,
        actions: [
          // Add a refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No classes available.'),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Populate Database'),
                  ),
                ],
              ),
            );
          }

          var classes = snapshot.data!;
          Map<String, List<Map<String, dynamic>>> groupedData = {};

          // Group the classes by department and batch
          for (var classData in classes) {
            String deptAndBatch =
                '${classData['department']} ${classData['batch']}';
            if (!groupedData.containsKey(deptAndBatch)) {
              groupedData[deptAndBatch] = [];
            }
            groupedData[deptAndBatch]!.add(classData);
          }

          return ListView.builder(
            itemCount: groupedData.keys.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              String key = groupedData.keys.elementAt(index);
              List<Map<String, dynamic>> deptBatchClasses = groupedData[key]!;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  deptBatchClasses[0]['imageUrl'] ?? ''),
                              backgroundColor: Colors.transparent,
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${deptBatchClasses[0]['department']} - ${deptBatchClasses[0]['batch']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Advisor: ${deptBatchClasses[0]['staff_advisor']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Classes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...deptBatchClasses.map((classData) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to detailed class page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ClassDetailPage(classData),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Text(
                                    classData['name'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Text(
                                      '${classData['devices']?.length ?? 0} Devices'),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ClassDetailPage extends StatelessWidget {
  final Map<String, dynamic> classData;

  ClassDetailPage(this.classData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classData['name']),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department: ${classData['department']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Batch: ${classData['batch']}'),
            Text('Advisor: ${classData['staff_advisor']}'),
            Text('Student Rep: ${classData['student_rep']}'),
            Divider(),
            Text(
              'Devices:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...((classData['devices'] as Map<String, dynamic>)
                .entries
                .map((device) => ListTile(
                      title: Text(device.key),
                      subtitle: _buildDeviceDetails(device.value),
                    ))
                .toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceDetails(Map<String, dynamic> deviceData) {
    List<Widget> details = [];

    if (deviceData['status'] != null) {
      details.add(Text('Status: ${deviceData['status']}'));
    }
    if (deviceData['value'] != null) {
      details.add(Text('Value: ${deviceData['value']}'));
    }
    if (deviceData['speed'] != null) {
      details.add(Text('Speed: ${deviceData['speed']}'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details,
    );
  }
}
