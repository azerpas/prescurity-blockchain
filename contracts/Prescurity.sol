// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title Prescription made by the doctor after a consultation
contract Prescurity {

    /**
     * @dev Owner should be the admin
     * He is responsible for adding Doctors and Pharmacists
     */
    address private _owner;

    uint private _doctorId;
    uint private _prescriptionId;

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
        address payable doctor_address;
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
        string medicine;
        string disease;
        string frequency;
        uint256 start_timestamp;
        uint256 end_timestamp;
        uint due_to_doctor;
        bool claimed;
        bool paid;
    } 

    // set owner as first interactor with the contract
    constructor() public {
        _set_owner(msg.sender);
        _setDoctorId(1);
        _setPrescriptionId(1);
    }

    enum authentification {
        anon,
        patient,
        doctor,
        pharmacy
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
    mapping (uint => Prescription) prescription_id_map;

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

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function append(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getDoctorId() internal returns (uint) {
        return _doctorId++;
    }

    function getPrescriptionId() internal returns (uint) {
        return _prescriptionId++;
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

    function add_doctor(address payable addr, string calldata name, string calldata speciality) external owner_only {
        require(doctor_authentification[addr] != authentification.doctor, "This address is already defined as a doctor");
        require(pharmacy_authentification[addr] != authentification.pharmacy, "This address is already defined as a doctor");
        uint id = getDoctorId();
        doctor_id_map[id].id = id;
        doctor_id_map[id].speciality = speciality;
        doctor_id_map[id].name = name;
        doctor_id_map[id].doctor_address = addr;
        doctor_id_map[id].isValue = true;
        doctor_address_map[addr].id = id;
        doctor_authentification[addr] = authentification.doctor;
    }

    function add_pharmacy(address addr, uint id, string calldata name) external owner_only {
        require(!pharmacy_id_map[id].isValue, "This address is already defined as a pharmacy");
        pharmacy_id_map[id].id = id;
        pharmacy_id_map[id].name = name;
        pharmacy_id_map[id].pharmacy_address = addr;
        pharmacy_id_map[id].isValue = true;
        pharmacy_address_map[addr].id = id;
        pharmacy_authentification[addr] = authentification.pharmacy;
    }

    /**
     * @dev problème: une personne mal-intentionée pourrait lier un numéro de sécu ne lui appartenant pas à une addresse quelconque 
     */
    function add_patient(uint numero_secu, address addr) external {
        require(!patient_num_secu_map[numero_secu].isValue, "This num secu is already defined as a patient");
        patient_num_secu_map[numero_secu].numero_secu = numero_secu;
        patient_num_secu_map[numero_secu].isValue = true;
        patient_num_secu_map[numero_secu].patient_address = addr;
        patient_authentification[addr] = authentification.patient;
    }

    function add_prescription(uint amountAskedByDoctor, uint numero_secu, string calldata medicine, string calldata disease, string calldata frequency) external doctor_only {
        //require(msg.value == amountAskedByDoctor, append("Please match the asked value by the doctor: ",uint2str(amountAskedByDoctor)));
        Doctor storage doctor = doctor_address_map[msg.sender];
        Patient storage patient = patient_num_secu_map[numero_secu];
        uint prescriptionId = getPrescriptionId();
        prescription_id_map[prescriptionId].id = prescriptionId;
        prescription_id_map[prescriptionId].claimed = false;
        prescription_id_map[prescriptionId].paid = false;
        prescription_id_map[prescriptionId].patient_id = numero_secu;
        prescription_id_map[prescriptionId].doctor_id = doctor.id;
        prescription_id_map[prescriptionId].medicine = medicine;
        prescription_id_map[prescriptionId].frequency = frequency;
        prescription_id_map[prescriptionId].disease = disease;
        prescription_id_map[prescriptionId].due_to_doctor = amountAskedByDoctor;
        prescription_id_map[prescriptionId].start_timestamp = block.timestamp;
        prescription_id_map[prescriptionId].end_timestamp = block.timestamp + 93 days;
        emit Consultation(prescription_id_map[prescriptionId], patient, doctor, amountAskedByDoctor);
    }

    function pay_prescription(uint prescriptionId) payable external patient_only {
        require(address(this).balance >= msg.value, "Balance is not enough");
        require(!prescription_id_map[prescriptionId].paid, "Prescription should not be paid");
        Prescription storage prescription = prescription_id_map[prescriptionId];
        Doctor storage doctor = doctor_id_map[prescription.doctor_id];
        address payable doctorAddr = doctor.doctor_address;
        doctorAddr.transfer(msg.value);
        emit LogDoctor(doctor.speciality, doctor.doctor_address, doctor.name, prescription.doctor_id);
        emit DoctorPaid(msg.value, doctor.doctor_address, msg.sender, prescription.doctor_id);
        prescription_id_map[prescriptionId].paid = true;
    }

    function claim_prescription(uint amountAskedByPharmacy, uint prescriptionId) external pharmacy_only {
        // set prescription_id_map[prescriptionId].claimed = true;
    }

    function _set_owner(address new_owner) private {
        address old_owner = _owner;
        _owner = new_owner;
        emit DefineOwnership(old_owner, new_owner);
    }

    function _setDoctorId(uint index) private {
        _doctorId = index;
    }

    function _setPrescriptionId(uint index) private {
        _prescriptionId = index;
    }
    
    event DefineOwnership(address indexed old_owner, address indexed new_owner);
    event Consultation(Prescription prescription, Patient patient, Doctor doctor, uint amount);
    event LogDoctor(string speciality, address indexed doctorAddress, string name, uint doctorId);
    event DoctorPaid(uint amount, address indexed doctorAddress, address indexed patientAddress, uint doctorId);
    event RetrieveMedicaments(Patient patient, Pharmacy pharmacy, Prescription prescription);
}