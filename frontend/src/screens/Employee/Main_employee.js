import React from "react";
// import Header from "../../components/header_user.js";
// import SwipeableTemporaryDrawer from "../../components/sidebar.employee.js";
export default function Home() {
	return (
		<div className='container mt-5'>
			<div className='d-flex justify-content-begin mt-4'>
				{/* <SwipeableTemporaryDrawer /> */}
				{/* <Header /> */}
			</div>
			<h1 className='mb-4'>Employee Home Page</h1>
			<p>
				Welcome to the Employee Home Page. Here, you can manage various aspects
				of your application.
			</p>
		</div>
	);
}
