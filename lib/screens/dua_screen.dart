import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double? width = MediaQuery.of(context).size.width;
    double? height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff076585),
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFFADB5BD)),
          title: Text(
            "All Dua",
            style: GoogleFonts.roboto(
              fontSize: 22,
              color: Color(0xFFADB5BD),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff076585), Color(0xfffff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("Dua").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
                var data = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = data[index];
                    return Column(
                      children: [
                        ExpansionTile(
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          tilePadding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          collapsedBackgroundColor: Colors.blueGrey.shade800,
                          backgroundColor: Colors.blueGrey.shade700,
                          childrenPadding: EdgeInsets.all(15),
                          title: Container(
                            height: height * 0.06,
                            width: width * 0.8,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              // border: Border.all(),
                              gradient: LinearGradient(
                                colors: [Color(0xff076585), Color(0xff42a5f5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              "${doc["duaName"]}",
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          children: [
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    child: Text(
                                      "${doc["dua"]}",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Divider(color: Colors.grey.shade300),
                                  SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    child: Text(
                                      "${doc["translation"]}",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
