import { useMemo, useState } from 'react';
import { MaterialReactTable } from 'material-react-table';
import { Box, IconButton } from '@mui/material';
import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';

function Payment() {
  const columns = useMemo(
    () => [
      {
        accessorKey: 'MaHoaDon',
        header: 'Mã hóa đơn',
      },
      {
        accessorKey: 'MaPhieuDVSD',
        header: 'Mã phiếu dịch vụ sử dụng',
      },
      {
        accessorKey: 'TongTien',
        header: 'Tổng tiền',
      },
      {
        accessorKey: 'MaDonThuoc',
        header: 'Mã đơn thuốc',
      },
      {
        accessorKey: 'TinhTrangThanhToan',
        header: 'Tình trạng thanh toán',
      },
      {
        accessorKey: 'NgayThanhToan',
        header: 'Ngày thanh toán',
      },
    ],
    []
  );

  const [Dulieu, setDulieu] = useState(null);

  const fetchService = async () => {
    const response = await fetch(`http://localhost:5000/api/receipts/getReceipt`);
    const serviceData = await response.json();
    if (serviceData) {
      const modifiedData = serviceData.map((item) => {
        const formattedNgayThanhToan = item.NgayThanhToan.split('T')[0];
        return { ...item, NgayThanhToan: formattedNgayThanhToan };
      });
      setDulieu(modifiedData);
    }
  };

  useEffect(() => {
    fetchService();
  }, []);

  if (!Dulieu) {
    return <div>Loading...</div>;
  }

  return (
    <div className='container mt-5'>
      <h1 className='mb-4'>Patient Home Page</h1>
      

      <MaterialReactTable
        columns={columns}
        data={Dulieu}
        renderRowActions={({ row, table }) => (
          <Box sx={{ display: 'flex', flexWrap: 'nowrap', gap: '8px' }}>
            <Link to='/'>View Details</Link>
            <IconButton
              color='secondary'
              onClick={() => {
                table.setEditingRow(row);
              }}
            ></IconButton>
            <IconButton
              color='error'
              onClick={() => {
                const updatedData = [...Dulieu];
                updatedData.splice(row.index, 1);
                setDulieu(updatedData);
              }}
            ></IconButton>
          </Box>
        )}
      />
    </div>
  );
}

export default Payment;
