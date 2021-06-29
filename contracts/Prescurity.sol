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
    uint private _pharmacyId;
    uint private _prescriptionId;

    struct Patient {
        uint numero_secu;
        address patientAddress;
        uint[] prescriptionsIds;
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
        _setPharmacyId(1);
        _setPrescriptionId(1);
    }

    enum authentification {
        anon,
        patient,
        doctor,
        pharmacy
    }

    mapping (uint => Patient) patientNumSecuMap;
    mapping(address => Patient) patientAddressMap;
    mapping (address => authentification) patientAuthentification;
    mapping (uint => Doctor) doctorIdMap;
    mapping (address => Doctor) doctorAddressMap;
    mapping (address => authentification) doctorAuthentification;
    mapping (uint => Pharmacy) pharmacyIdMap;
    mapping (address => Pharmacy) pharmacyAddressMap;
    mapping (address => authentification) pharmacyAuthentification;
    mapping (uint => Prescription) prescIdMap;
    mapping (uint => Prescription) prescriptionIdMap;

    modifier patientOnly() {
        if (patientAuthentification[msg.sender] == authentification.patient) {
            _;
        } else {
            revert("Sorry, this function is reserved to the patient");
        }
    }

    modifier doctorOnly() {
        if (doctorAuthentification[msg.sender] == authentification.doctor) {
            _;
        } else {
            revert("Sorry, this function is reserved to the doctor");
        }
    }
    
    modifier pharmacyOnly(){
        if (pharmacyAuthentification[msg.sender] == authentification.pharmacy) {
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
        if (doctorAuthentification[msg.sender] == authentification.doctor) {
            return "doctor";
        }
        if (pharmacyAuthentification[msg.sender] == authentification.pharmacy) {
            return "pharmacy";
        }
        if (patientAuthentification[msg.sender] == authentification.patient) {
            return "patient";
        }
        if(msg.sender == getOwner()){
            return "owner";
        }
        return "none";
    }

    function addDoctor(address payable addr, string calldata name, string calldata speciality) external ownerOnly {
        require(doctorAuthentification[addr] != authentification.doctor, "This address is already defined as a doctor");
        require(pharmacyAuthentification[addr] != authentification.pharmacy, "This address is already defined as a doctor");
        uint id = getDoctorId();
        doctorIdMap[id].id = id;
        doctorIdMap[id].speciality = speciality;
        doctorIdMap[id].name = name;
        doctorIdMap[id].doctorAddress = addr;
        doctorIdMap[id].isValue = true;
        doctorAddressMap[addr].id = id;
        doctorAuthentification[addr] = authentification.doctor;
    }

    function addPharmacy(address addr, string calldata name) external ownerOnly {
        require(pharmacyAuthentification[addr] != authentification.pharmacy, "This address is already defined as a doctor");
        require(doctorAuthentification[addr] != authentification.doctor, "This address is already defined as a doctor");
        uint id = getDoctorId();
        pharmacyIdMap[id].id = id;
        pharmacyIdMap[id].name = name;
        pharmacyIdMap[id].pharmacyAddress = addr;
        pharmacyIdMap[id].isValue = true;
        pharmacyAddressMap[addr].id = id;
        pharmacyAuthentification[addr] = authentification.pharmacy;
    }

    /**
     * @dev problème: une personne mal-intentionée pourrait lier un numéro de sécu ne lui appartenant pas à une addresse quelconque 
     */
    function addPatient(uint numero_secu, address addr) external {
        require(!patientNumSecuMap[numero_secu].isValue, "This num secu is already defined as a patient");
        patientNumSecuMap[numero_secu].numero_secu = numero_secu;
        patientNumSecuMap[numero_secu].isValue = true;
        patientNumSecuMap[numero_secu].patientAddress = addr;
        patientAuthentification[addr] = authentification.patient;
    }

    function addPrescription(uint amountAskedByDoctor, uint numero_secu, string calldata medicine, string calldata disease, string calldata frequency) external doctorOnly {
        //require(msg.value == amountAskedByDoctor, append("Please match the asked value by the doctor: ",uint2str(amountAskedByDoctor)));
        Doctor storage doctor = doctorAddressMap[msg.sender];
        Patient storage patient = patientNumSecuMap[numero_secu];
        uint prescriptionId = getPrescriptionId();
        prescriptionIdMap[prescriptionId].id = prescriptionId;
        prescriptionIdMap[prescriptionId].claimed = false;
        prescriptionIdMap[prescriptionId].paid = false;
        prescriptionIdMap[prescriptionId].patientId = numero_secu;
        prescriptionIdMap[prescriptionId].doctorId = doctor.id;
        prescriptionIdMap[prescriptionId].medicine = medicine;
        prescriptionIdMap[prescriptionId].frequency = frequency;
        prescriptionIdMap[prescriptionId].disease = disease;
        prescriptionIdMap[prescriptionId].dueToDoctor = amountAskedByDoctor;
        prescriptionIdMap[prescriptionId].startTimestamp = block.timestamp;
        prescriptionIdMap[prescriptionId].endTimestamp = block.timestamp + 93 days;
        emit Consultation(prescriptionIdMap[prescriptionId], patient, doctor, amountAskedByDoctor);
    }

    function payPrescription(uint prescriptionId) payable external patientOnly {
        require(address(this).balance >= msg.value, "Balance is not enough");
        require(!prescriptionIdMap[prescriptionId].paid, "Prescription should not be paid");
        Prescription storage prescription = prescriptionIdMap[prescriptionId];
        Doctor storage doctor = doctorIdMap[prescription.doctorId];
        address payable doctorAddr = doctor.doctorAddress;
        doctorAddr.transfer(msg.value);
        emit DoctorPaid(msg.value, doctor.doctorAddress, msg.sender, prescription.doctorId);
        prescriptionIdMap[prescriptionId].paid = true;
    }

    function claimPrescription(uint amountAskedByPharmacy, uint prescriptionId) external pharmacyOnly {
        // require(prescriptionIdMap[prescriptionId].claimed == false, "sinon");
        // set prescriptionIdMap[prescriptionId].claimed = true;
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

    function _setPharmacyId(uint index) private {
        _pharmacyId = index;
    }

    function _setPrescriptionId(uint index) private {
        _prescriptionId = index;
    }
    
    event DefineOwnership(address indexed old_owner, address indexed new_owner);
    event Consultation(Prescription prescription, Patient patient, Doctor doctor, uint amount);
    event DoctorPaid(uint amount, address indexed doctorAddress, address indexed patientAddress, uint doctorId);
    event RetrieveMedicaments(Patient patient, Pharmacy pharmacy, Prescription prescription);
}