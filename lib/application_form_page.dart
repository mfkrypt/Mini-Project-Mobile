import 'package:flutter/material.dart';

class ApplicationFormPage extends StatefulWidget {
  @override
  _ApplicationFormPageState createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  String companyName = '';
  String description = '';

  bool chairs = false;
  bool wifi = false;
  bool carpet = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Application Form")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Company Details"),
              TextFormField(
                decoration: InputDecoration(labelText: "Company Name"),
                onSaved: (val) => companyName = val!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Exhibit Description"),
                maxLines: 3,
                onSaved: (val) => description = val!,
              ),
              SizedBox(height: 20),
              Text("Add-ons"),
              CheckboxListTile(
                title: Text("Extra Chairs (\$100)"),
                value: chairs,
                onChanged: (val) => setState(() => chairs = val!),
              ),
              CheckboxListTile(
                title: Text("Premium Wifi (\$100)"),
                value: wifi,
                onChanged: (val) => setState(() => wifi = val!),
              ),
              CheckboxListTile(
                title: Text("Carpet (\$100)"),
                value: carpet,
                onChanged: (val) => setState(() => carpet = val!),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Application Submitted")),
                    );
                  }
                },
                child: Text("Submit Application"),
              )
            ],
          ),
        ),
      ),
    );
  }
}