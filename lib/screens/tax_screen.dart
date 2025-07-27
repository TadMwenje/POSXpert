import 'package:flutter/material.dart';
import '../widgets/tax_style.dart';

class TaxScreen extends StatelessWidget {
  final TextEditingController _tinController =
      TextEditingController(text: '123456789');
  final TextEditingController _vatController =
      TextEditingController(text: '263789541');
  final TextEditingController _defaultRateController =
      TextEditingController(text: '15');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tax Configuration', style: TaxStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(value: true, onChanged: (val) {}),
              Text('Enable Tax Calculation',
                  style: TaxStyles.checkboxTextStyle),
            ],
          ),
          const SizedBox(height: 20),
          _buildTaxInfoTable(),
          const SizedBox(height: 40),
          Text('VAT Number', style: TaxStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          TextField(
            controller: _vatController,
            style: TaxStyles.tableValueStyle,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Checkbox(value: false, onChanged: (val) {}),
              Text('Prices Include Tax', style: TaxStyles.checkboxTextStyle),
            ],
          ),
          const SizedBox(height: 40),
          Text('Tax Rates', style: TaxStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildTaxRatesTable(),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF363753),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child:
                  Text('Save Tax Settings', style: TaxStyles.saveButtonStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxInfoTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text('Tin Number', style: TaxStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: _tinController,
                style: TaxStyles.tableValueStyle,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text('Default Tax Rate (%)',
                  style: TaxStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: _defaultRateController,
                style: TaxStyles.tableValueStyle,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaxRatesTable() {
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text('Tax Name', style: TaxStyles.tableHeaderStyle),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text('Rate (%)', style: TaxStyles.tableHeaderStyle),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text('Actions', style: TaxStyles.tableHeaderStyle),
                ),
              ],
            ),
          ],
        ),
        _buildTaxRateRow('VAT', '15.00'),
        _buildTaxRateRow('Sales Tax', '7.50'),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {},
          child: Text('Add New Rate', style: TaxStyles.addNewRateStyle),
        ),
      ],
    );
  }

  Widget _buildTaxRateRow(String name, String rate) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(name, style: TaxStyles.tableValueStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(rate, style: TaxStyles.tableValueStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextButton(
                onPressed: () {},
                child: Text('Remove', style: TaxStyles.removeButtonStyle),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
