package com.example.saphcm.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportDto {
    private String title;
    private String type;
    private String period;
    private List<String> columns;
    private List<Map<String, Object>> rows;
    private String exportPdfMessage;
    private String exportExcelMessage;
}
