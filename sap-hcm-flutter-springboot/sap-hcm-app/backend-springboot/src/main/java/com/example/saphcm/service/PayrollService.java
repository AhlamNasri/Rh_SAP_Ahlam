package com.example.saphcm.service;

import com.example.saphcm.dto.PayrollDto;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.entity.Payroll;
import com.example.saphcm.enums.PayrollStatus;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.EmployeeRepository;
import com.example.saphcm.repository.PayrollRepository;
import com.example.saphcm.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
@Transactional
public class PayrollService {
    private final PayrollRepository payrollRepository;
    private final EmployeeRepository employeeRepository;
    private final CurrentUserService current;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public List<PayrollDto> findAll() {
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "La paie globale est reservee a RH/Admin");
        }
        return payrollRepository.findAll().stream().map(mapper::toPayrollDto).toList();
    }

    @Transactional(readOnly = true)
    public List<PayrollDto> myPayrolls() {
        Employee me = current.currentEmployee();
        return payrollRepository.findByEmployeeIdOrderByMonthDesc(me.getId()).stream().map(mapper::toPayrollDto).toList();
    }

    @Transactional(readOnly = true)
    public PayrollDto getById(Long id) {
        Payroll payroll = get(id);
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            Employee me = current.currentEmployee();
            if (!payroll.getEmployee().getId().equals(me.getId())) {
                throw new ApiException(HttpStatus.FORBIDDEN, "Acces fiche de paie non autorise");
            }
        }
        return mapper.toPayrollDto(payroll);
    }

    public PayrollDto create(PayrollDto dto) {
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Creation paie reservee RH/Admin");
        }
        Employee employee = employeeRepository.findById(dto.getEmployeeId())
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Employe introuvable"));
        Payroll payroll = new Payroll();
        payroll.setEmployee(employee);
        payroll.setMonth(dto.getMonth());
        payroll.setBaseSalary(nvl(dto.getBaseSalary()));
        payroll.setBonuses(nvl(dto.getBonuses()));
        payroll.setOvertime(nvl(dto.getOvertime()));
        payroll.setDeductions(nvl(dto.getDeductions()));
        payroll.setCharges(nvl(dto.getCharges()));
        payroll.setGrossSalary(payroll.getBaseSalary().add(payroll.getBonuses()).add(payroll.getOvertime()));
        payroll.setNetSalary(payroll.getGrossSalary().subtract(payroll.getDeductions()).subtract(payroll.getCharges()));
        payroll.setPaymentDate(dto.getPaymentDate());
        payroll.setStatus(dto.getStatus() != null ? dto.getStatus() : PayrollStatus.EN_ATTENTE);
        return mapper.toPayrollDto(payrollRepository.save(payroll));
    }

    @Transactional(readOnly = true)
    public byte[] generatePayslipPdf(Long id) {
        PayrollDto payroll = getById(id);
        List<String> lines = List.of(
                "FICHE DE PAIE",
                "Mois: " + value(payroll.getMonth()),
                "Employe: " + value(payroll.getEmployeeName()),
                "Departement: " + value(payroll.getDepartmentName()),
                "Date de paiement: " + formatDate(payroll),
                "Statut: " + value(payroll.getStatus()),
                "",
                "Salaire de base: " + money(payroll.getBaseSalary()) + " MAD",
                "Primes: " + money(payroll.getBonuses()) + " MAD",
                "Heures supplementaires: " + money(payroll.getOvertime()) + " MAD",
                "Salaire brut: " + money(payroll.getGrossSalary()) + " MAD",
                "Deductions: " + money(payroll.getDeductions()) + " MAD",
                "Charges: " + money(payroll.getCharges()) + " MAD",
                "Net a payer: " + money(payroll.getNetSalary()) + " MAD",
                "",
                "Document genere automatiquement par SAP HCM RH."
        );
        return buildSimplePdf(lines);
    }

    private Payroll get(Long id) {
        return payrollRepository.findById(id).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Fiche de paie introuvable"));
    }

    private BigDecimal nvl(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }

    private String value(Object value) {
        return value != null ? value.toString() : "-";
    }

    private String money(BigDecimal value) {
        return nvl(value).stripTrailingZeros().toPlainString();
    }

    private String formatDate(PayrollDto payroll) {
        return payroll.getPaymentDate() != null ? payroll.getPaymentDate().format(DateTimeFormatter.ISO_LOCAL_DATE) : "-";
    }

    private byte[] buildSimplePdf(List<String> lines) {
        StringBuilder content = new StringBuilder();
        content.append("BT\n/F1 20 Tf\n50 790 Td\n(").append(pdfEscape(lines.get(0))).append(") Tj\n");
        content.append("/F1 11 Tf\n0 -34 Td\n");
        for (int i = 1; i < lines.size(); i++) {
            content.append("(").append(pdfEscape(lines.get(i))).append(") Tj\n0 -18 Td\n");
        }
        content.append("ET\n");

        byte[] stream = content.toString().getBytes(StandardCharsets.ISO_8859_1);
        List<String> objects = new ArrayList<>();
        objects.add("1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n");
        objects.add("2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n");
        objects.add("3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>\nendobj\n");
        objects.add("4 0 obj\n<< /Length " + stream.length + " >>\nstream\n" + content + "endstream\nendobj\n");
        objects.add("5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n");

        ByteArrayOutputStream output = new ByteArrayOutputStream();
        write(output, "%PDF-1.4\n");
        List<Integer> offsets = new ArrayList<>();
        for (String object : objects) {
            offsets.add(output.size());
            write(output, object);
        }
        int xrefOffset = output.size();
        write(output, "xref\n0 " + (objects.size() + 1) + "\n");
        write(output, "0000000000 65535 f \n");
        for (Integer offset : offsets) {
            write(output, String.format(Locale.ROOT, "%010d 00000 n \n", offset));
        }
        write(output, "trailer\n<< /Size " + (objects.size() + 1) + " /Root 1 0 R >>\nstartxref\n" + xrefOffset + "\n%%EOF");
        return output.toByteArray();
    }

    private void write(ByteArrayOutputStream output, String value) {
        output.writeBytes(value.getBytes(StandardCharsets.ISO_8859_1));
    }

    private String pdfEscape(String value) {
        return value.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)");
    }
}
