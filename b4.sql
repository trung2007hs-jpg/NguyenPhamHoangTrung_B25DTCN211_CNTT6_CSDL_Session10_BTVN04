CREATE TABLE Pharmacy_Inventory (
    Inventory_ID INT AUTO_INCREMENT PRIMARY KEY,
    Drug_Name VARCHAR(255),
    Batch_Number VARCHAR(50),
    Expiry_Date DATE,
    Quantity INT
);

-- Procedure nạp 2.000.000 lô thuốc để kiểm tra hiệu năng dữ liệu lớn
DELIMITER //
CREATE PROCEDURE SeedMassiveData()
BEGIN
    DECLARE i INT DEFAULT 1;
    SET autocommit = 0; -- Tắt tự động commit để tăng tốc độ chèn dữ liệu
    SET unique_checks = 0;
    WHILE i <= 2000000 DO
        INSERT INTO Pharmacy_Inventory (Drug_Name, Batch_Number, Expiry_Date, Quantity)
        VALUES (
            CONCAT('Drug_', (i % 1000)), 
            CONCAT('BATCH-', i), 
            DATE_ADD('2024-01-01', INTERVAL (i % 1000) DAY), 
            FLOOR(RAND() * 1000)
        );
        -- Commit định kỳ mỗi 50.000 dòng để tránh tràn bộ nhớ log
        IF i % 50000 = 0 THEN
            COMMIT;
        END IF;
        SET i = i + 1;
    END WHILE;
    SET autocommit = 1;
    SET unique_checks = 1;
    COMMIT;
END //
DELIMITER ;

-- Thực thi nạp dữ liệu
CALL SeedMassiveData();

-- Triển khai Composite Index tối ưu cho truy vấn (Drug_Name, Expiry_Date)
CREATE INDEX idx_drug_expiry ON Pharmacy_Inventory(Drug_Name, Expiry_Date);

-- Giải pháp khắc phục tìm kiếm nâng cao: Full-Text Search
ALTER TABLE Pharmacy_Inventory ADD FULLTEXT(Drug_Name);

-- Câu lệnh EXPLAIN chứng minh hiệu quả
-- Lọc theo tên chính xác và khoảng thời gian (Sử dụng Composite Index)
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE Drug_Name = 'Drug_100' AND Expiry_Date <= '2025-12-31';

-- Kiểm tra tìm kiếm Full-Text (Thay thế cho LIKE %keyword%)
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE MATCH(Drug_Name) AGAINST('Drug_100');