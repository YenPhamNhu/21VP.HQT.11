import React from "react";
import PatientAccountManagement from "../../components/accManagement_patient";
import EmployeeAccountManagement from "../../components/accManagement_employee";
import DentistAccountManagement from "../../components/accManagement_dentist";

export default function Home() {
  return (
    <div className='container mt-5 mb-5'>
      <div>
        <h3>Quản lý bệnh nhân</h3>
        <PatientAccountManagement />
      </div>
      <div>
        <h3 className='mt-5'>Quản lý nhân viên</h3>
        <EmployeeAccountManagement />
      </div>
      <div>
        <h3 className='mt-5'>Quản lý nha sĩ</h3>
        <DentistAccountManagement />
      </div>
    </div>
  );
}
