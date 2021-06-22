// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title Prescription made by the doctor after a consultation
contract Prescurity {

    struct Patient {
        uint id;
        string name;
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
}