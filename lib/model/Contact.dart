class Contact {
  String name, email;

  Contact();

  Contact.map(dynamic obj) {
    this.email = obj['EMAIL'];
    this.name = obj['NAME'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['EMAIL'] = this.email;
    map['NAME'] = this.name;
  }
}
