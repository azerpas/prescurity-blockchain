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
        address patientAddress;
        uint[] prescriptions_ids;
        bool isValue;
    }

    struct Doctor {
        uint id;
        string speciality;
        string name;
        address payable doctorAddress;
        bool isValue;
    }

    struct Pharmacy {
        uint id;
        string name;
        address pharmacyAddress;
        bool isValue;
    }
    
    struct Prescription {
        uint id;
        uint patientId;
        uint doctorId;
        string medicine;
        string disease;
        string frequency;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint dueToDoctor;
        bool claimed;
        bool paid;
    } 

    // set owner as first interactor with the contract
    constructor() public {
        _setOwner(msg.sender);
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

    modifier patientOnly() {
        if (patient_authentification[msg.sender] == authentification.patient) {
            _;
        } else {
            revert("Sorry, this function is reserved to the patient");
        }
    }

    modifier doctorOnly() {
        if (doctor_authentification[msg.sender] == authentification.doctor) {
            _;
        } else {
            revert("Sorry, this function is reserved to the doctor");
        }
    }
    
    modifier pharmacyOnly(){
        if (pharmacy_authentification[msg.sender] == authentification.pharmacy) {
            _;
        } else {
            revert("Sorry, this function is reserved to the pharmacy");
        }
    }
    
    modifier ownerOnly(){
        if (getOwner() == msg.sender) {
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

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getDoctorId() internal returns (uint) {
        return _doctorId++;
    }

    function getPrescriptionId() internal returns (uint) {
        return _prescriptionId++;
    }

    function getUserType() view public returns (string memory) {
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

    function addDoctor(address payable addr, string calldata name, string calldata speciality) external ownerOnly {
        require(doctor_authentification[addr] != authentification.doctor, "This address is already defined as a doctor");
        require(pharmacy_authentification[addr] != authentification.pharmacy, "This address is already defined as a doctor");
        uint id = getDoctorId();
        doctor_id_map[id].id = id;
        doctor_id_map[id].speciality = speciality;
        doctor_id_map[id].name = name;
        doctor_id_map[id].doctorAddress = addr;
        doctor_id_map[id].isValue = true;
        doctor_address_map[addr].id = id;
        doctor_authentification[addr] = authentification.doctor;
    }

    function addPharmacy(address addr, uint id, string calldata name) external ownerOnly {
        require(!pharmacy_id_map[id].isValue, "This address is already defined as a pharmacy");
        pharmacy_id_map[id].id = id;
        pharmacy_id_map[id].name = name;
        pharmacy_id_map[id].pharmacyAddress = addr;
        pharmacy_id_map[id].isValue = true;
        pharmacy_address_map[addr].id = id;
        pharmacy_authentification[addr] = authentification.pharmacy;
    }

    /**
     * @dev problème: une personne mal-intentionée pourrait lier un numéro de sécu ne lui appartenant pas à une addresse quelconque 
     */
    function addPatient(uint numero_secu, address addr) external {
        require(!patient_num_secu_map[numero_secu].isValue, "This num secu is already defined as a patient");
        patient_num_secu_map[numero_secu].numero_secu = numero_secu;
        patient_num_secu_map[numero_secu].isValue = true;
        patient_num_secu_map[numero_secu].patientAddress = addr;
        patient_authentification[addr] = authentification.patient;
    }

    function addPrescription(uint amountAskedByDoctor, uint numero_secu, string calldata medicine, string calldata disease, string calldata frequency) external doctorOnly {
        //require(msg.value == amountAskedByDoctor, append("Please match the asked value by the doctor: ",uint2str(amountAskedByDoctor)));
        Doctor storage doctor = doctor_address_map[msg.sender];
        Patient storage patient = patient_num_secu_map[numero_secu];
        uint prescriptionId = getPrescriptionId();
        prescription_id_map[prescriptionId].id = prescriptionId;
        prescription_id_map[prescriptionId].claimed = false;
        prescription_id_map[prescriptionId].paid = false;
        prescription_id_map[prescriptionId].patientId = numero_secu;
        prescription_id_map[prescriptionId].doctorId = doctor.id;
        prescription_id_map[prescriptionId].medicine = medicine;
        prescription_id_map[prescriptionId].frequency = frequency;
        prescription_id_map[prescriptionId].disease = disease;
        prescription_id_map[prescriptionId].dueToDoctor = amountAskedByDoctor;
        prescription_id_map[prescriptionId].startTimestamp = block.timestamp;
        prescription_id_map[prescriptionId].endTimestamp = block.timestamp + 93 days;
        emit Consultation(prescription_id_map[prescriptionId], patient, doctor, amountAskedByDoctor);
    }

    function payPrescription(uint prescriptionId) payable external patientOnly {
        require(address(this).balance >= msg.value, "Balance is not enough");
        require(!prescription_id_map[prescriptionId].paid, "Prescription should not be paid");
        Prescription storage prescription = prescription_id_map[prescriptionId];
        Doctor storage doctor = doctor_id_map[prescription.doctorId];
        address payable doctorAddr = doctor.doctorAddress;
        doctorAddr.transfer(msg.value);
        emit DoctorPaid(msg.value, doctor.doctorAddress, msg.sender, prescription.doctorId);
        prescription_id_map[prescriptionId].paid = true;
    }

    function claimPrescription(uint amountAskedByPharmacy, uint prescriptionId) external pharmacyOnly {
        // require(prescription_id_map[prescriptionId].claimed == false, "sinon");
        // set prescription_id_map[prescriptionId].claimed = true;
        // emit MedicineGiven(...);
    }

    function _setOwner(address new_owner) private {
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
    event DoctorPaid(uint amount, address indexed doctorAddress, address indexed patientAddress, uint doctorId);
    event RetrieveMedicaments(Patient patient, Pharmacy pharmacy, Prescription prescription);
}