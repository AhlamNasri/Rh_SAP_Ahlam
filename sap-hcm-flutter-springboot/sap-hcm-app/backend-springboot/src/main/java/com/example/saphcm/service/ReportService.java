package com.example.saphcm.service;

import com.example.saphcm.dto.ReportDto;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReportService {
    private final LeaveRequestRepository leaveRepository;
    private final AttendanceRepository attendanceRepository;
    private final PayrollRepository payrollRepository;
    private final TrainingRepository trainingRepository;
    private final TrainingEnrollmentRepository enrollmentRepository;
    private final PerformanceReviewRepository performanceRepository;
    private final DtoMapper mapper;

    public ReportDto leaves() {
        return report("Rapport des conges", "LEAVES", List.of("Employe", "Type", "Debut", "Fin", "Jours", "Statut"),
                leaveRepository.findAll().stream().map(l -> row(
                        "Employe", l.getEmployee().getFullName(),
                        "Type", l.getType().name(),
                        "Debut", l.getStartDate().toString(),
                        "Fin", l.getEndDate().toString(),
                        "Jours", l.getDays(),
                        "Statut", l.getStatus().name()
                )).toList());
    }

    public ReportDto attendance() {
        return report("Rapport des presences", "ATTENDANCE", List.of("Employe", "Date", "Entree", "Sortie", "Heures", "Statut"),
                attendanceRepository.findAll().stream().map(a -> row(
                        "Employe", a.getEmployee().getFullName(),
                        "Date", a.getDate().toString(),
                        "Entree", a.getCheckInTime(),
                        "Sortie", a.getCheckOutTime(),
                        "Heures", a.getTotalHours(),
                        "Statut", a.getStatus().name()
                )).toList());
    }

    public ReportDto payroll() {
        return report("Rapport de paie", "PAYROLL", List.of("Employe", "Mois", "Brut", "Deductions", "Net", "Statut"),
                payrollRepository.findAll().stream().map(p -> row(
                        "Employe", p.getEmployee().getFullName(),
                        "Mois", p.getMonth(),
                        "Brut", p.getGrossSalary(),
                        "Deductions", p.getDeductions().add(p.getCharges()),
                        "Net", p.getNetSalary(),
                        "Statut", p.getStatus().name()
                )).toList());
    }

    public ReportDto trainings() {
        return report("Rapport des formations", "TRAININGS", List.of("Formation", "Formateur", "Statut", "Inscrits"),
                trainingRepository.findAll().stream().map(t -> row(
                        "Formation", t.getTitle(),
                        "Formateur", t.getTrainer(),
                        "Statut", t.getStatus().name(),
                        "Inscrits", enrollmentRepository.findByTrainingId(t.getId()).size()
                )).toList());
    }

    public ReportDto performance() {
        return report("Rapport des evaluations", "PERFORMANCE", List.of("Employe", "Manager", "Periode", "Score", "Statut"),
                performanceRepository.findAll().stream().map(r -> row(
                        "Employe", r.getEmployee().getFullName(),
                        "Manager", r.getManager() != null ? r.getManager().getFullName() : "-",
                        "Periode", r.getPeriod(),
                        "Score", r.getScore(),
                        "Statut", r.getStatus().name()
                )).toList());
    }

    private ReportDto report(String title, String type, List<String> columns, List<Map<String, Object>> rows) {
        return ReportDto.builder()
                .title(title)
                .type(type)
                .period("Demo - filtres applicables cote UI")
                .columns(columns)
                .rows(rows)
                .exportPdfMessage("Export PDF simule: fichier genere dans une integration future")
                .exportExcelMessage("Export Excel simule: fichier genere dans une integration future")
                .build();
    }

    private Map<String, Object> row(Object... kv) {
        Map<String, Object> row = new LinkedHashMap<>();
        for (int i = 0; i < kv.length; i += 2) {
            row.put(String.valueOf(kv[i]), kv[i + 1]);
        }
        return row;
    }
}
