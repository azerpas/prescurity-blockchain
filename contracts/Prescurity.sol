// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title Prescription made by the doctor after a consultation
contract Prescurity {
    address internal owner;
    struct Admin {
        uint id;
        address admin_address;
        bool isValue;
     }

    struct Patient {
        uint numero_secu;
        address patient_address;
        uint[] prescriptions_ids;
        bool isValue;
    }

    struct Doctor {
        uint id;
        string speciality;
        string name;
        address doctor_address;
        bool isValue;
    }

    struct Pharmacy {
        uint id;
        string name;
        address pharmacy_address;
        bool isValue;
    }
    
    struct Prescription {
        string frequency;
        string start_timestamp;
        string end_timestamp;
        bool isValue;
    } 

    constructor() public {
        owner=msg.sender;
    }


enum authentification {
        anon,
        patient,
        doctor,
        pharmacy,
        admin
    }

    mapping (uint => Patient) patient_num_secu_map;
    mapping (address => authentification) patient_authentification;
    mapping (uint => Doctor) doctor_id_map;
    mapping (address => Doctor) doctor_address_map;
    mapping (address => authentification) doctor_authentification;
    mapping (uint => Pharmacy) pharma_id_map;
    mapping (address => Pharmacy) pharmacy_address_map;
    mapping (address => authentification) pharmacy_authentification;
    mapping (uint => Prescription) presc_id_map;
    mapping (address => authentification) admin_authentification;

    modifier patient_only() {
        if (patient_authentification[msg.sender] == authentification.patient) {
            _;
        } else {
            revert("Sorry, this function is reserved to the patient");
        }
    }

 modifier doctor_only() {
        if (doctor_authentification[msg.sender] == authentification.doctor) {
            _;
        } else {
            revert("Sorry, this function is reserved to the doctor");
        }
    }
    modifier pharmacy_only(){
        if (pharmacy_authentification[msg.sender] == authentification.pharmacy) {
            _;
        } else {
            revert("Sorry, this function is reserved to the pharmacy");
        }
    }
    modifier admin_only(){
        if (admin_authentification[msg.sender] == authentification.admin) {
            _;
        } else {
             revert("Sorry, this function is reserved to the admin");
         }
     }

     function add_doctor(address addr, uint id, string calldata name, string calldata speciality) external admin_only {
         require(doctor_address_map[addr].isValue, "This address is already defined as a doctor");
         doctor_address_map[addr].id = id;
         doctor_address_map[addr].speciality = speciality;
         doctor_address_map[addr].name = name;
         doctor_address_map[addr].doctor_address = addr;
         doctor_address_map[addr].isValue = true;
         doctor_authentification[addr] = authentification.doctor;
     }
 

    function add_pharmacy(address addr, uint id, string calldata name) external admin_only {
         require(pharmacy_address_map[addr].isValue, "This address is already defined as a doctor");
         pharmacy_address_map[addr].id = id;
         pharmacy_address_map[addr].name = name;
         pharmacy_address_map[addr].pharmacy_address = addr;
         pharmacy_address_map[addr].isValue = true;
         pharmacy_authentification[addr] = authentification.pharmacy;
     }


     event Consultation(Patient patient, Doctor doctor, uint amount);







}