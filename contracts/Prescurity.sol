// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title Prescription made by the doctor after a consultation
contract Prescurity {

    struct Admin {
        uint id;
        address admin_address;
        bool exists;
    }

    struct Patient {
        uint id;
        string name;
        uint numero_secu;
        address patient_address;
        uint[] prescriptions_ids;
    }

    struct Doctor {
        uint id;
        string speciality;
        string name;
        address doctor_address;
    }

    struct Pharmacy {
        uint id;
        string name;
        address pharmacy_address;
    }
    
    struct Prescription {
        uint id;
        uint patient_id;
        uint doctor_id;
        uint pharmacy_id;
        string medicine;
        string disease;
        string frequency;
        string start_timestamp;
        string end_timestamp;
    }

    event Consultation(Patient patient, Doctor doctor, uint amount); 

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
}