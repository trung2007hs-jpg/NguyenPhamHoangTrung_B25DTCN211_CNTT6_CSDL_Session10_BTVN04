CREATE TABLE Pharmacy_Inventory (
    Inventory_ID INT AUTO_INCREMENT PRIMARY KEY,
    Drug_Name VARCHAR(255),
    Batch_Number VARCHAR(50),
    Expiry_Date DATE,
    Quantity INT
);

INSERT INTO Pharmacy_Inventory (Drug_Name, Batch_Number, Expiry_Date, Quantity) VALUES
('Paracetamol', 'BATCH001', '2026-12-31', 1000),
('Antibiotic A', 'BATCH002', '2025-05-20', 500),
('Vitamin C', 'BATCH003', '2024-10-15', 2000),
('Insulin', 'BATCH004', '2027-01-01', 100);

-- Tạo 2 Single Index độc lập (Để so sánh)
CREATE INDEX idx_drug_name ON Pharmacy_Inventory(Drug_Name);
CREATE INDEX idx_expiry_date ON Pharmacy_Inventory(Expiry_Date);

-- Xóa Index cũ và tạo Composite Index (Tối ưu cho yêu cầu bài toán)
DROP INDEX idx_drug_name ON Pharmacy_Inventory;
DROP INDEX idx_expiry_date ON Pharmacy_Inventory;
CREATE INDEX idx_drug_expiry ON Pharmacy_Inventory(Drug_Name, Expiry_Date);

-- Câu lệnh kiểm tra hiệu năng
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE Drug_Name = 'Paracetamol' AND Expiry_Date <= '2026-12-31';

-- Chạy lệnh này để thấy Index vẫn hoạt động (type = range/ref)
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE Drug_Name LIKE 'Para%';

-- Chạy lệnh này để thấy Index bị VÔ HIỆU HÓA (type = ALL)
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE Drug_Name LIKE '%Para%';