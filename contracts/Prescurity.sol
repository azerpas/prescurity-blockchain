// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title Prescription made by the doctor after a consultation
contract Prescurity {
    address private _owner;
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
        uint id;
        uint patient_id;
        uint doctor_id;
        uint pharmacy_id;
        string medicine;
        string disease;
        string frequency;
        string start_timestamp;
        string end_timestamp;
        bool isValue;
    } 

    // set owner as first interactor with the contract
    constructor() {
        _set_owner(msg.sender);
    }

    enum authentification {
        anon,
        patient,
        doctor,
        pharmacy,
        admin
    }

    mapping (uint => Patient) patient_num_secu_map;
    mapping(address => Patient) patient_address_map;
    mapping (address => authentification) patient_authentification;
    mapping (uint => Doctor) doctor_id_map;
    mapping (address => Doctor) doctor_address_map;
    mapping (address => authentification) doctor_authentification;
    mapping (uint => Pharmacy) pharmacy_id_map;
    mapping (address => Pharmacy) pharmacy_address_map;
    mapping (address => authentification) pharmacy_authentification;
    mapping (uint => Prescription) presc_id_map;
    mapping(uint => Admin) admin_id_map;
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

    function get_user_type() view public returns (string memory) {
        if (doctor_authentification[msg.sender] == authentification.doctor) {
            return "doctor";
        }
        if (pharmacy_authentification[msg.sender] == authentification.pharmacy) {
            return "pharmacy";
        }
        if (patient_authentification[msg.sender] == authentification.patient) {
            return "patient";
        }
        return "none";
    }

    function add_doctor(address addr, uint id, string calldata name, string calldata speciality) external admin_only {
        require(!doctor_id_map[id].isValue, "This address is already defined as a doctor");
        doctor_id_map[id].id = id;
        doctor_id_map[id].speciality = speciality;
        doctor_id_map[id].name = name;
        doctor_id_map[id].doctor_address = addr;
        doctor_id_map[id].isValue = true;
        doctor_authentification[addr] = authentification.doctor;
    }

    function add_pharmacy(address addr, uint id, string calldata name) external admin_only {
        require(!pharmacy_id_map[id].isValue, "This address is already defined as a pharmacy");
        pharmacy_id_map[id].id = id;
        pharmacy_id_map[id].name = name;
        pharmacy_id_map[id].pharmacy_address = addr;
        pharmacy_id_map[id].isValue = true;
        pharmacy_authentification[addr] = authentification.pharmacy;
    }

    function set_admin(address addr, uint id) private {
        require(!admin_id_map[id].isValue, "This address is already defined as a admin");
        admin_id_map[id].id=id;
        admin_id_map[id].isValue=true;
        admin_authentification[addr] = authentification.admin;
    }

    function add_patient(uint numero_secu, address addr) external {
        require(!patient_num_secu_map[numero_secu].isValue, "This address is already defined as a patient");
        patient_num_secu_map[numero_secu].numero_secu=numero_secu;
        patient_num_secu_map[numero_secu].isValue=true;
        patient_authentification[addr]=authentification.patient;
    }

    function _set_owner(address new_owner) private {
        address old_owner = _owner;
        _owner = new_owner;
        //TODO: set admin to new owner
        emit DefineOwnership(old_owner, new_owner);
    }
    
    event DefineOwnership(address indexed old_owner, address indexed new_owner);
    event Consultation(Patient patient, Doctor doctor, uint amount);
    event RetrieveMedicaments(Patient patient, Pharmacy pharmacy, Prescription prescription);
}