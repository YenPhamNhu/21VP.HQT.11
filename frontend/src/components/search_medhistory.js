import { useMemo, useState } from 'react';
import { MaterialReactTable } from 'material-react-table';
import { Box, IconButton } from '@mui/material';
import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';

export const Search = () => {
  const columns = useMemo(
    () => [
        {
            accessorKey: 'STT',
            header: 'Số thứ tự',
          },
          {
            accessorKey: 'MaBenhNhan',
            header: 'Mã bệnh nhân',
          },
          {
            accessorKey: 'MaNhaSiKham',
            header: 'Mã nha sĩ',
          },
          {
            accessorKey: 'NgayKham',
            header: 'Ngày khám',
          },
          {
            accessorKey: 'GhiChu',
            header: 'Ghi chú',
          },
    ],
    []
  );

  
  const [Dulieu, setDulieu] = useState(null);

  const fetchService = async () => {

    const response = await fetch(
      `http://localhost:5000/api/medHistory/getAllMedHistory`
    ); // Fetch service data
    console.log(response);
    const serviceData = await response.json();
    if (serviceData) {
      const modifiedData = serviceData.map((item) => {
        const formattedNgayKham = item.NgayKham.split('T')[0]; // Extract the date part
        return { ...item, NgayKham: formattedNgayKham };
      });
        setDulieu(modifiedData);
    }
  };

  useEffect(() => {
    fetchService(); 
  }, []); 
  if (!Dulieu) {
    return <div>Loading...</div>; // Display loading message while fetching data
  }


  return (
    <MaterialReactTable
      columns={columns}
      data={Dulieu}
      renderRowActions={({ row, table }) => (
        <Box sx={{ display: 'flex', flexWrap: 'nowrap', gap: '8px' }}>

          <Link to="/">
            View Details
          </Link>
          <IconButton
            color="secondary"
            onClick={() => {
              table.setEditingRow(row);
            }}
          >
          </IconButton>
          <IconButton
            color="error"
            onClick={() => {
              const updatedData = [...Dulieu];
              updatedData.splice(row.index, 1); // Assuming simple data table
              setDulieu(updatedData);
            }}
          >
            {/* Add your icon component code */}
          </IconButton>
        </Box>
      )}
    />
  );
};

export default Search;