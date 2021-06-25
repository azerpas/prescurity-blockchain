// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title Prescription made by the doctor after a consultation
contract Prescurity {
    address private _owner;

    struct Patient {
        uint numero_secu;
        address patient_address;
        uint[] prescriptions_ids;
        bool isValue;
    }
    
    struct Consultation{
        uint amount;
        bool paid;
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

     constructor() {
         _set_owner(msg.sender);
     }


    enum authentification {
        anon,
        patient,
        doctor,
        pharmacy
    }

    mapping(address=>Consultation) consultations;
    mapping (uint => Patient) patient_num_secu_map;
    mapping (address=>bool) wallets;
    mapping(address => Patient) patient_address_map;
    mapping (address => authentification) patient_authentification;
    mapping (uint => Doctor) doctor_id_map;
    mapping (address => Doctor) doctor_address_map;
    mapping (address => authentification) doctor_authentification;
    mapping (uint => Pharmacy) pharmacy_id_map;
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
    
    modifier owner_only(){
         if (owner() == msg.sender) {
             _;
         } else {
             revert("Sorry, this function is reserved to the owner of the smart contract");
         }
     }
     
     function setWallet(address _wallet) public{
        wallets[_wallet]=true;
    }
    
     function owner() public view virtual returns (address) {
         return _owner;
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

    function add_doctor(address addr, uint id, string calldata name, string calldata speciality) external owner_only {
        require(!doctor_id_map[id].isValue, "This id is already defined as a doctor");
        require(!wallets[addr], "This address is already defined");
        doctor_id_map[id].id = id;
        doctor_id_map[id].speciality = speciality;
        doctor_id_map[id].name = name;
        doctor_id_map[id].doctor_address = addr;
        doctor_id_map[id].isValue = true;
        doctor_authentification[addr] = authentification.doctor;
        setWallet(addr);
    }

    function add_pharmacy(address addr, uint id, string calldata name) external owner_only {
        require(!pharmacy_id_map[id].isValue, "This address is already defined as a pharmacy");
        require(!wallets[addr], "This address is already defined");
        pharmacy_id_map[id].id = id;
        pharmacy_id_map[id].name = name;
        pharmacy_id_map[id].pharmacy_address = addr;
        pharmacy_id_map[id].isValue = true;
        pharmacy_authentification[addr] = authentification.pharmacy;
        setWallet(addr);
    }

    function add_patient(uint numero_secu, address addr) external  {
        require(!patient_num_secu_map[numero_secu].isValue, "This id is already defined as a patient");
        require(!wallets[addr], "This address is already defined");
        patient_num_secu_map[numero_secu].numero_secu=numero_secu;
        patient_num_secu_map[numero_secu].isValue=true;
        patient_authentification[addr] = authentification.patient;
        setWallet(addr);
    }
    
    
    function _set_owner(address new_owner) private {
         address old_owner = _owner;
         _owner = new_owner;
         setWallet(new_owner);
         //TODO: set admin to new owner
         emit DefineOwnership(old_owner, new_owner);
     }
     
     function payementConsultation() payable external {
        Consultation storage consultation = consultations[msg.sender];
        require(consultation.amount >= 25 ether,'not enought');
        require(consultation.paid == false,'deja recup');
        consultation.paid=true;
        payable(msg.sender).transfer(consultation.amount);
     } 
     
     function addConsultation(address addr) external payable{
         consultations[addr]=Consultation(msg.value,false);
         
     }


    event DefineOwnership(address indexed old_owner, address indexed new_owner);
    event Consultationev(address patient, address doctor, uint amount);
    event RetrieveMedicaments(Patient patient, Pharmacy pharmacy, Prescription prescription);
}