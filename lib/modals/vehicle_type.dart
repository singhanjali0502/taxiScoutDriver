class VechicalType {
  bool? success;
  String? message;
  DriverVehicle? driverVehicle;
  List<DriverVehicle>? data;

  VechicalType({this.success, this.message, this.driverVehicle, this.data});

  VechicalType.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    driverVehicle = json['driver_vehicle'] != null
        ? new DriverVehicle.fromJson(json['driver_vehicle'])
        : null;
    if (json['data'] != null) {
      data = <DriverVehicle>[];
      json['data'].forEach((v) {
        data!.add(new DriverVehicle.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.driverVehicle != null) {
      data['driver_vehicle'] = this.driverVehicle!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DriverVehicle {
  String? id;
  Null? companyKey;
  String? ownerId;
  String? name;
  String? icon;
  Null? iconTypesFor;
  Null? tripDispatchType;
  int? capacity;
  Null? luggage;
  String? modelName;
  int? size;
  Null? description;
  Null? shortDescription;
  Null? supportedVehicles;
  int? isAcceptShareRide;
  int? active;
  int? smoking;
  int? pets;
  int? drinking;
  int? handicaped;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;
  String? isTaxi;

  DriverVehicle(
      {this.id,
        this.companyKey,
        this.ownerId,
        this.name,
        this.icon,
        this.iconTypesFor,
        this.tripDispatchType,
        this.capacity,
        this.luggage,
        this.modelName,
        this.size,
        this.description,
        this.shortDescription,
        this.supportedVehicles,
        this.isAcceptShareRide,
        this.active,
        this.smoking,
        this.pets,
        this.drinking,
        this.handicaped,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.isTaxi});

  DriverVehicle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyKey = json['company_key'];
    ownerId = json['owner_id'];
    name = json['name'];
    icon = json['icon'];
    iconTypesFor = json['icon_types_for'];
    tripDispatchType = json['trip_dispatch_type'];
    capacity = json['capacity'];
    luggage = json['luggage'];
    modelName = json['model_name'];
    size = json['size'];
    description = json['description'];
    shortDescription = json['short_description'];
    supportedVehicles = json['supported_vehicles'];
    isAcceptShareRide = json['is_accept_share_ride'];
    active = json['active'];
    smoking = json['smoking'];
    pets = json['pets'];
    drinking = json['drinking'];
    handicaped = json['handicaped'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    isTaxi = json['is_taxi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['company_key'] = this.companyKey;
    data['owner_id'] = this.ownerId;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['icon_types_for'] = this.iconTypesFor;
    data['trip_dispatch_type'] = this.tripDispatchType;
    data['capacity'] = this.capacity;
    data['luggage'] = this.luggage;
    data['model_name'] = this.modelName;
    data['size'] = this.size;
    data['description'] = this.description;
    data['short_description'] = this.shortDescription;
    data['supported_vehicles'] = this.supportedVehicles;
    data['is_accept_share_ride'] = this.isAcceptShareRide;
    data['active'] = this.active;
    data['smoking'] = this.smoking;
    data['pets'] = this.pets;
    data['drinking'] = this.drinking;
    data['handicaped'] = this.handicaped;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['is_taxi'] = this.isTaxi;
    return data;
  }
}
