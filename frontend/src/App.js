import React, { useEffect, useState,Navigate } from "react";
import {BrowserRouter,Routes,Route,} from "react-router-dom";
import "./App.css";
import About from "./screens/About.js";
import Service from "./screens/Service.js";
import Login from "./screens/Login.js";
import Logout from "./screens/Logout.js";
import Signup from "./screens/Signup.js";
import Footer from "./components/footer.js";
import Main from "./components/main.js";
import Header from "./components/header.js";
import Forgetpass from "./screens/Forgetpass.js";
import ServiceDetails from "./screens/Service_detail.js";
import Resetpass from "./screens/Resetpass.js";
import MainPatient from "./screens/Patient/Main_patient.js";
import DetailPatient from "./screens/Patient/Detail_patient.js";
import SetdatePatient from "./screens/Patient/Setdate_patient.js";
import DentistPatient from "./screens/Patient/Dentist_patient.js";
import ProfilePatient from "./screens/Patient/Profile_patient.js";
import PaymentPatient from "./screens/Patient/Payment_patient.js";
import MainDentist from "./screens/Dentist/Main_dentist.js";
import DetailDentist from "./screens/Dentist/Detail_dentist.js";
import SearchDentist from "./screens/Dentist/Dentist_search.js";
import ListDate from "./screens/Dentist/ListDate_dentist.js";
import ListMed from "./screens/Dentist/ListMed_dentist.js";
import Schedule from "./screens/Dentist/Schedule_dentist.js";
import UpdatePatient from "./screens/Dentist/UpdateProfile_patient.js";
import MainEmployee from "./screens/Employee/Main_employee.js";
import CreateProfile from "./screens/Employee/CreateProfile_employee.js";
import DetailEmployee from "./screens/Employee/Detail_employee.js";
import ListMedEmployee from "./screens/Employee/ListMed_employee.js";
import PaymentEmployee from "./screens/Employee/Payment_employee.js";
import SearchEmployee from "./screens/Employee/Search_employee.js";
import SearchProfileEmployee from "./screens/Employee/SearchProfile_employee.js";
import SetdateEmployee from "./screens/Employee/Setdate_employee.js";
import UpdatePatientEmployee from "./screens/Employee/UpdatePatient_employee.js";

import MainAdmin from "./screens/Admin/Main_admin.js";
import DetailAdmin from "./screens/Admin/Detail_admin.js";
import AccountManage from "./screens/Admin/AccountManagement.js";
import Dashboard from "./screens/Admin/Dashboard.js";
import InfoAppo from "./screens/Admin/InfoAppointement.js";
import StoreMed from "./screens/Admin/StoreMed.js";
import SidebarPatient from "./components/sidebar_patient.js";
import SidebarEmployee from "./components/sidebar.employee.js";
import SidebarDentist from "./components/sidebar_dentist.js";
import SidebarAdmin from "./components/sidebar_admin.js";

import LichLamViec from "./screens/Admin/Lich_lam_viec.js"
import LichLamViecDentist from "./screens/Dentist/Lich_lam_viec.js"
// import { useContext } from "react";
// import { Store } from "./Store.js";
// import { useSelector } from "react-redux";
// import LogoutPage from "./components/Logout.js";
import "./App.css";

// import { Link } from 'react-router-dom';

const USER_TYPES = {
	PUBLIC: "Public User",
	ADMIN_USER: "Admin User",
	PATIENT_USER: "Patient User",
	EMPLOYEE_USER: "Employee User",
	DENTIST_USER: "Dentist User",
};

function App({ item_Type }) {	
	const [userType, setUserType] = useState(USER_TYPES.PUBLIC);
	useEffect(() => {
		const handleLoginSuccess = () => {
		  if (sessionStorage.item_Type) {
			// Set the user type based on the item_Type from the login session
			switch (sessionStorage.item_Type) {
			  case "Admin User":
				setUserType(USER_TYPES.ADMIN_USER);
				break;
			  case "Patient User":
				setUserType(USER_TYPES.PATIENT_USER);
				break;
			  case "Employee User":
				setUserType(USER_TYPES.EMPLOYEE_USER);
				break;
			  case "Dentist User":
				setUserType(USER_TYPES.DENTIST_USER);
				break;
			  default:
				setUserType(USER_TYPES.PUBLIC);
			}
		  }
		};
		const handleLogout = () => {
			// Clear the user type or perform any necessary cleanup
			setUserType(USER_TYPES.PUBLIC);
		  };

	
		// Add event listener for the custom event
		window.addEventListener("logout", handleLogout);
		window.addEventListener("loginSuccess", handleLoginSuccess);
		  
		if (sessionStorage.item_Type) {
			handleLoginSuccess();
		  }
		// Clean up the event listener
		return () => {
			window.removeEventListener("logout", handleLogout);
			window.removeEventListener("loginSuccess", handleLoginSuccess);
			console.log(localStorage);
		  };
		
	  }, []);
	

	
	function PublicElement({ children }) {
		if (userType === USER_TYPES.PUBLIC) {
			return <>{children}</>;
		} else {
			return <div>You do not have access to this page!</div>;
		}
	}
	
	function AdminElement({ children }) {
		if (userType === USER_TYPES.ADMIN_USER) {
			return <>{children}</>;
		} else {
			return <div>You do not have access to this page!</div>;
		}
	}
	
	function PatientElement({ children }) {
		if (userType === USER_TYPES.PATIENT_USER) {
			return <>{children}</>;
		} else {
			return <div>You do not have access to this page!</div>;
		}
	}
	
	function EmployeeElement({ children }) {
		if (userType === USER_TYPES.EMPLOYEE_USER) {
			return <>{children}</>;
		} else {
			return <div>You do not have access to this page!</div>;
		}
	}
	
	function DentistElement({ children }) {
		if (userType === USER_TYPES.DENTIST_USER) {
			return <>{children}</>;
		} else {
			return <div>You do not have access to this page!</div>;
		}
	}
		
	return (
		<BrowserRouter>
		    {userType === USER_TYPES.PUBLIC && <Header />}
			{userType === USER_TYPES.PATIENT_USER && <SidebarPatient />}
			{userType === USER_TYPES.ADMIN_USER && <SidebarAdmin />}
			{userType === USER_TYPES.DENTIST_USER && <SidebarDentist />}
			{userType === USER_TYPES.EMPLOYEE_USER && <SidebarEmployee />}
		  <Routes>
			<Route path="/" element={<PublicElement><Main /></PublicElement>} />
			<Route path="/about" element={<About />} />
			<Route path="/service" element={<Service/>}/>
			<Route path="/login" element={<PublicElement><Login /></PublicElement>} />
			<Route path="/signup" element={<PublicElement><Signup /></PublicElement>} />
			<Route path="/forgetpass" element={<PublicElement><Forgetpass /></PublicElement>} />
			<Route path="/resetpass" element={<PublicElement><Resetpass /></PublicElement>} />
			<Route path="/service/:number" element={<PublicElement><ServiceDetails /></PublicElement>} />
			<Route path="/patient" element={<PatientElement><MainPatient /></PatientElement>} />
			<Route path="/patient/detail" element={<PatientElement><DetailPatient /></PatientElement>} />
			<Route path="/patient/setdate" element={<PatientElement><SetdatePatient /></PatientElement>} />
			<Route path="/patient/dentist" element={<PatientElement><DentistPatient /></PatientElement>} />
			<Route path="/patient/profile" element={<PatientElement><ProfilePatient /></PatientElement>} />
			<Route path="/patient/payment" element={<PatientElement><PaymentPatient /></PatientElement>} />
			<Route path="/dentist" element={<DentistElement><MainDentist /></DentistElement>} />
			<Route path="/dentist/detail" element={<DentistElement><DetailDentist /></DentistElement>} />
			<Route path="/dentist/search" element={<DentistElement><SearchDentist /></DentistElement>} />
			<Route path="/dentist/listdate" element={<DentistElement><ListDate /></DentistElement>} />
			<Route path="/dentist/listmed" element={<DentistElement><ListMed /></DentistElement>} />
			<Route path="/dentist/schedule" element={<DentistElement><Schedule /></DentistElement>} />
			<Route path="/dentist/updatepatient" element={<DentistElement><UpdatePatient /></DentistElement>} />
			<Route path="/dentist/lichlamviec" element={<DentistElement><LichLamViecDentist /></DentistElement>} />
			<Route path="/employee" element={<EmployeeElement><MainEmployee /></EmployeeElement>} />
			<Route path="/employee/create" element={<EmployeeElement><CreateProfile /></EmployeeElement>} />
			<Route path="/employee/detail" element={<EmployeeElement><DetailEmployee /></EmployeeElement>} />
			<Route path="/employee/listmed" element={<EmployeeElement><ListMedEmployee /></EmployeeElement>} />
			<Route path="/employee/payment" element={<EmployeeElement><PaymentEmployee /></EmployeeElement>} />
			<Route path="/employee/search" element={<EmployeeElement><SearchEmployee /></EmployeeElement>} />
			<Route path="/employee/searchprofile" element={<EmployeeElement><SearchProfileEmployee /></EmployeeElement>} />
			<Route path="/employee/setdate" element={<EmployeeElement><SetdateEmployee /></EmployeeElement>} />
			<Route path="/employee/updatepatient" element={<EmployeeElement><UpdatePatientEmployee /></EmployeeElement>} />
			<Route path="/admin" element={<AdminElement><MainAdmin /></AdminElement>} />
			<Route path="/admin/detail" element={<AdminElement><DetailAdmin /></AdminElement>} />
			<Route path="/admin/account" element={<AdminElement><AccountManage /></AdminElement>} />
			<Route path="/admin/dashboard" element={<AdminElement><Dashboard /></AdminElement>} />
			<Route path="/admin/infoappo" element={<AdminElement><InfoAppo /></AdminElement>} />
			<Route path="/admin/storemed" element={<AdminElement><StoreMed /></AdminElement>} />
			<Route path="/admin/lichlamviec" element={<AdminElement><LichLamViec /></AdminElement>} />
			<Route path="*" element={<div>Page Not Found!</div>} />
			<Route path="/logout" element={<Logout/>} />
		  </Routes>
		  <hr id="hrduoi" />
		  <Footer />
		</BrowserRouter>
	  );}

	  
export default App;
