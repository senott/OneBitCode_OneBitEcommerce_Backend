shared_examples 'paginatable concern' do |factory_name|
  describe 'when records fit page size' do
    let!(:records) { create_list(factory_name, 20) }

    context 'when :page and :length are empty' do
      before(:each) { @paginated_records = described_class.paginate(nil, nil) }

      it 'should return 10 records default' do
        expect(@paginated_records.count).to eq(10)
      end

      it 'should match first ten records' do
        expected_records = described_class.all[0..9]

        expect(@paginated_records).to eq(expected_records)
      end
    end

    context 'when :page is informed and :length is empty' do
      let(:page) { 2 }

      before(:each) { @paginated_records = described_class.paginate(page, nil) }

      it 'should return 10 records default' do
        expect(@paginated_records.count).to eq(10)
      end

      it 'should return 10 records from the right page' do
        first_record_index = 10
        last_record_index = 19
        expected_records = described_class.all[first_record_index..last_record_index]

        expect(@paginated_records).to eq(expected_records)
      end
    end

    context 'when :page and :length are informed and fits record size' do
      let(:page) { 2 }
      let(:length) { 5 }

      before(:each) { @paginated_records = described_class.paginate(page, length) }

      it 'should return right quantity of records' do
        expect(@paginated_records.count).to eq(length)
      end

      it 'should return records from the right page' do
        first_record_index = 5
        last_record_index = 9
        expected_records = described_class.all[first_record_index..last_record_index]

        expect(@paginated_records).to eq(expected_records)
      end
    end

    context 'when :page and :length are informed and does not fit record size' do
      let(:page) { 2 }
      let(:length) { 30 }

      before(:each) { @paginated_records = described_class.paginate(page, length) }

      it 'should not return any records' do
        expect(@paginated_records.count).to eq(0)
      end

      it 'should return empty results' do
        expect(@paginated_records).to_not be_present
      end
    end
  end

  describe 'when records does not fit page size' do
    let!(:records) { create_list(factory_name, 7) }

    context 'when :page and :length are empty' do
      before(:each) { @paginated_records = described_class.paginate(nil, nil) }

      it 'should return 7 records' do
        expect(@paginated_records.count).to eq(7)
      end

      it 'should match first 7 records' do
        expected_records = described_class.all[0..6]

        expect(@paginated_records).to eq(expected_records)
      end
    end

    context 'when :page is informed and :length is empty' do
      let(:page) { 2 }

      before(:each) { @paginated_records = described_class.paginate(page, nil) }

      it 'should not return any records' do
        expect(@paginated_records.count).to eq(0)
      end

      it 'should return empty results' do
        expect(@paginated_records).to_not be_present
      end
    end

    context 'when :page and :length are informed' do
      let(:page) { 2 }
      let(:length) { 5 }

      before(:each) { @paginated_records = described_class.paginate(page, length) }

      it 'should return right quantity of records' do
        expect(@paginated_records.count).to eq(2)
      end

      it 'should return records from the right page' do
        first_record_index = 5
        last_record_index = 6
        expected_records = described_class.all[first_record_index..last_record_index]

        expect(@paginated_records).to eq(expected_records)
      end
    end
  end
end
