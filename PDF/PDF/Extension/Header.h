import pdfplumber
import csv
import pandas as pd
 
# 读取PDF文件中的表格数据
def extract_tables_from_pdf(file_path):
    tables = []
    with pdfplumber.open(file_path) as pdf:
        for i, page in enumerate(pdf.pages):
            tables.append(page.extract_tables())  # 提取当前页面的表格数据
    return tables
 
# 将提取的数据保存为CSV文件
def save_to_csv(tables, output_csv):
    with open(output_csv, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        for table in tables:  # 这里假设每个表格都是我们要处理的“行”数据
            for row in table[0]:  # 遍历表格的每一行数据
                writer.writerow(row)  # 将每一行写入CSV文件
    return csvfile.name  # 返回CSV文件的路径，用于后续导入Excel
 
# 主程序部分，调用上述函数并处理结果
pdf_path = 'path_to_your_pdf_file.pdf'  # PDF文件路径
csv_path = save_to_csv(extract_tables_from_pdf(pdf_path), 'output.csv')  # 保存为CSV文件
df = pd.read_csv(csv_path)  # 使用pandas读取CSV文件到DataFrame中
df.to_excel('output.xlsx', index=False)  # 将DataFrame保存为Excel文件（如果需要保留原始格式，可能需要进一步处理）
